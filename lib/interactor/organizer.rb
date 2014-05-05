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
            instance = interactor.call(context)
          rescue
            rollback
            raise
          end

          rollback && break if failure?
          called << instance
        end
      end

      def rollback
        called.reverse_each(&:rollback)
      end

      def called
        @called ||= []
      end
    end
  end
end
