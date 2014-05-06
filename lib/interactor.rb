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
      new(context).tap(&:call_with_hooks).context
    end

    def rollback(context = {})
      new(context).tap(&:rollback).context
    end

    def before(&hook)
      before_hooks.push(hook)
    end

    def after(&hook)
      after_hooks.unshift(hook)
    end

    def before_hooks
      @before_hooks ||= []
    end

    def after_hooks
      @after_hooks ||= []
    end
  end

  def initialize(context = {})
    @context = Context.build(context)
  end

  def call_with_hooks
    call_before_hooks
    call
    call_after_hooks
  end

  def call
  end

  def rollback
  end

  private

  def call_before_hooks
    call_hooks(self.class.before_hooks)
  end

  def call_after_hooks
    call_hooks(self.class.after_hooks)
  end

  def call_hooks(hooks)
    hooks.each { |hook| instance_eval(&hook) }
  end
end
