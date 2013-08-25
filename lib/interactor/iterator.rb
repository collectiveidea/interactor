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
        collection.each do |element|
          perform_each(element)
          rollback && break if failure?
          performed << element
        end
      end

      def rollback
        performed.reverse_each { |e| rollback_each(e) }
      end

      def performed
        @performed ||= []
      end

      def perform_each(*)
      end

      def rollback_each(*)
      end
    end
  end
end
