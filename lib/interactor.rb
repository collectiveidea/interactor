require "interactor/context"
require "interactor/hooks"
require "interactor/organizer"

module Interactor
  def self.included(base)
    base.class_eval do
      extend ClassMethods
      include Hooks

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
  end

  def initialize(context = {})
    @context = Context.build(context)
  end

  def call_with_hooks
    with_hooks { call }
  end

  def call
  end

  def rollback
  end
end
