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
        interactors.each do |interactor|
          performed << interactor
          interactor.perform(context)
          rollback && break if context.failure?
        end
      end

      def rollback
        performed.reverse_each do |interactor|
          interactor.rollback(context)
        end
      end

      def performed
        @performed ||= []
      end
    end
  end
end
