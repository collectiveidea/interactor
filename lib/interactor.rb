require "interactor/context"
require "interactor/organizer"

module Interactor
  def self.included(base)
    base.class_eval do
      extend ClassMethods

      attr_reader :context
    end
  end

  module ClassMethods
    def call(context = {})
      instance = new(context)
      context = instance.context
      instance.call unless context.failure?
      context
    end

    def rollback(context = {})
      instance = new(context)
      instance.rollback
      instance.context
    end
  end

  def initialize(context = {})
    @context = Context.build(context)
    setup
  end

  def setup
  end

  def call
  end

  def rollback
  end
end
