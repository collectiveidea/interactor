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
      def organize(*interactors)
        @interactors = interactors.flatten
      end

      def interactors
        @interactors ||= []
      end
    end

    module InstanceMethods
      def perform
        return _interactors if failure?

        _interactors.each do |interactor|
          begin
            instance = interactor.perform(context)
          rescue
            rollback
            raise
          end

          rollback && break if failure?
          _performed << instance
        end
      end

      def rollback
        _performed.reverse_each(&:rollback)
      end

      private

      def _interactors
        self.class.interactors
      end

      def _performed
        @performed ||= []
      end
    end
  end
end
