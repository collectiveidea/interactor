require "interactor/context"

module Interactor
  def self.included(base)
    base.class_eval do
      extend ClassMethods
      include InstanceMethods

      attr_reader :context
    end
  end

  module ClassMethods
    def perform(context = {})
      new(context).tap(&:perform)
    end

    def interactors
      @interactors ||= []
    end

    def organize(*interactors)
      @interactors = interactors.flatten
    end

    def rollback(context = {})
      new(context).tap(&:rollback)
    end
  end

  module InstanceMethods
    def initialize(context = {})
      @context = Context.build(context)
    end

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

    def success?
      context.success?
    end

    def failure?
      context.failure?
    end

    def method_missing(method, *)
      context.fetch(method) { super }
    end

    def respond_to_missing?(method, *)
      context.key?(method) || super
    end
  end
end
