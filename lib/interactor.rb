require "interactor/context"
require "interactor/error"
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

    def perform!(context = {})
      new(context).tap(&:perform!)
    end
  end

  def initialize(context = {})
    @context = Context.build(context)
  end

  def perform
    perform!
  rescue Failure
  end

  def perform!
    before
    run
  rescue Success
  end

  def before
  end

  def run
  end

  def rollback
  end

  def success?
    context.success?
  end

  def failure?
    context.failure?
  end

  def succeed!(*args)
    context.succeed!(*args)
    raise Success
  end

  def fail!(*args)
    context.fail!(*args)
    raise Failure
  end

  def method_missing(method, *)
    context.fetch(method) { context.fetch(method.to_s) { super } }
  end

  def respond_to_missing?(method, *)
    (context && (context.key?(method) || context.key?(method.to_s))) || super
  end
end
