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
  end

  module InstanceMethods
    def initialize(context = {})
      @context = Context.build(context)
    end
  end
end
