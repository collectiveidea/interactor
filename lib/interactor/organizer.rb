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
          interactor.call!(context)
        end
      end
    end
  end
end
