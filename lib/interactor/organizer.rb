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

      def perform
        return interactors if failure?

        interactors.each do |interactor|
          begin
            instance = interactor.perform(context)
          rescue
            rollback
            raise
          end

          rollback && break if failure?
          performed << instance
        end
      end

      def rollback
        performed.reverse_each(&:rollback)
      end

      def performed
        @performed ||= []
      end
    end
  end
end
