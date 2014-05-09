module Interactor
  module Organizer
    def self.included(base)
      base.class_eval do
        include Interactor

        extend ClassMethods
        include InstanceMethods
      end
    end

    module ClassMethods
      def interactors
        @interactors ||= []
      end

      def organize(*interactors)
        @interactors = interactors.flatten
      end
    end

    module InstanceMethods
      def interactors
        self.class.interactors
      end

      def call
        interactors.each do |interactor|
          begin
            interactor.call!(context)
          rescue
            rollback_called
            raise
          end

          rollback_called && break if context.failure?
          called << interactor
        end
      end

      def rollback
        interactors.reverse_each do |interactor|
          interactor.rollback(context)
        end
      end

      def rollback_called
        called.reverse_each do |interactor|
          interactor.rollback(context)
        end
      end

      def called
        @called ||= []
      end
    end
  end
end
