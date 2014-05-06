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
      new(context).tap do |instance|
        instance.call unless instance.context.failure?
      end
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
