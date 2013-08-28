module Interactor
  module Iterator
    def self.included(base)
      base.class_eval do
        include Interactor

        extend ClassMethods
        include InstanceMethods
      end
    end

    module ClassMethods
      def collect(key)
        @collection_key = key
      end

      def collection_key
        @collection_key
      end
    end

    module InstanceMethods
      def perform
        return _collection if failure?

        _collection.each_with_index do |(*element), index|
          element << index
          _send_with_index(:perform_each, *element)
          rollback && break if failure?
          _performed << element
        end
      end

      def rollback
        _performed.reverse_each do |element|
          _send_with_index(:rollback_each, *element)
        end
      end

      def perform_each(*)
      end

      def rollback_each(*)
      end

      private

      def _collection
        context.fetch(self.class.collection_key) { [] }
      end

      def _performed
        @performed ||= []
      end

      def _send_with_index(method_name, *args)
        method = self.method(method_name)
        args.pop if (0...args.size).cover?(method.arity)
        method.call(*args)
      end
    end
  end
end
