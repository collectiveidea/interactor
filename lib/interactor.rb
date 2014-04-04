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
    catch(:halt!) do
      before
      run

      if catch(:halt!) { after } == :failure!
        rollback
        throw :halt!, :failure!
      end
    end
  end

  def perform!
    perform
    raise Failure if failure?
  end

  def before
  end

  def run
  end

  def after
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
    throw :halt!, :success!
  end

  def fail!(*args)
    context.fail!(*args)
    throw :halt!, :failure!
  end

  def method_missing(method, *)
    context.fetch(method) { context.fetch(method.to_s) { super } }
  end

  def respond_to_missing?(method, *)
    (context && (context.key?(method) || context.key?(method.to_s))) || super
  end
end
