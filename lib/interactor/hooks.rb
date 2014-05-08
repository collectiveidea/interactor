module Interactor
  module Hooks
    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end

    module ClassMethods
      def before(*hooks, &block)
        hooks << block if block
        hooks.each { |hook| before_hooks.push(hook) }
      end

      def after(*hooks, &block)
        hooks << block if block
        hooks.each { |hook| after_hooks.unshift(hook) }
      end

      def before_hooks
        @before_hooks ||= []
      end

      def after_hooks
        @after_hooks ||= []
      end
    end

    private

    def before_hooks
      self.class.before_hooks
    end

    def after_hooks
      self.class.after_hooks
    end

    def with_hooks
      call_before_hooks
      yield
      call_after_hooks
    end

    def call_before_hooks
      call_hooks(before_hooks)
    end

    def call_after_hooks
      call_hooks(after_hooks)
    end

    def call_hooks(hooks)
      hooks.each { |hook| call_hook(hook) }
    end

    def call_hook(hook)
      hook.is_a?(Symbol) ? method(hook).call : instance_eval(&hook)
    end
  end
end
