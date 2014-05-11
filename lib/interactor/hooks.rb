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

    def with_hooks
      run_before_hooks
      yield
      run_after_hooks
    end

    def run_before_hooks
      run_hooks(self.class.before_hooks)
    end

    def run_after_hooks
      run_hooks(self.class.after_hooks)
    end

    def run_hooks(hooks)
      hooks.each { |hook| run_hook(hook) }
    end

    def run_hook(hook)
      hook.is_a?(Symbol) ? send(hook) : instance_eval(&hook)
    end
  end
end
