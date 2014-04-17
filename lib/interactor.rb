require "interactor/context"
require "interactor/success"
require "interactor/failure"
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
      new(context).tap do |instance|
        instance.perform unless instance.failure?
        yield Success.new(instance), Failure.new(instance) if block_given?
      end
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
    context.fetch(method) { context.fetch(method.to_s) { super } }
  end

  def respond_to_missing?(method, *)
    (context && (context.key?(method) || context.key?(method.to_s))) || super
  end
end
