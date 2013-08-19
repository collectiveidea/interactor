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
    def perform(context = {})
      new(context).tap(&:perform)
    end
  end

  def initialize(context = {})
    @context = Context.build(context)
    setup
  end

  def setup
  end

  def perform
  end

  def rollback
  end

  def success?
    context.success?
  end

  def failure?
    context.failure?
  end

  def fail!(*args)
    context.fail!(*args)
  end

  def method_missing(method, *)
    context.fetch(method) { super }
  end

  def respond_to_missing?(method, *)
    context.key?(method) || super
  end
end
