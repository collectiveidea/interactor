require "interactor/context"
require "interactor/error"
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
      new(context).tap(&:run).context
    end

    def call!(context = {})
      new(context).tap(&:run!).context
    end

    def rollback(context = {})
      new(context).tap(&:rollback).context
    end
  end

  def initialize(context = {})
    @context = Context.build(context)
  end

  def run
    run!
  rescue Failure
  end

  def run!
    with_hooks do
      call
      context.called!(self.class)
    end
  rescue
    context.rollback!
    raise
  end

  def call
  end

  def rollback
  end
end
