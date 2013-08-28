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
      def collection
        @collection
      end

      def collect(key)
        @collection = key
      end
    end

    module InstanceMethods
      def collection
        context.fetch(self.class.collection, [])
      end

      def perform
        return collection if failure?

        collection.each_with_index do |(*element), index|
          element << index
          send_with_index(:perform_each, *element)
          rollback && break if failure?
          performed << element
        end
      end

      def rollback
        performed.reverse_each do |element|
          send_with_index(:rollback_each, *element)
        end
      end

      def performed
        @performed ||= []
      end

      def perform_each(*)
      end

      def rollback_each(*)
      end

      private

      def send_with_index(method_name, *args)
        method = self.method(method_name)
        args.pop if (0...args.size).cover?(method.arity)
        method.call(*args)
      end
    end
  end
end
