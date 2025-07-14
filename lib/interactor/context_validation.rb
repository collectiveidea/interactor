module Interactor
  module ContextValidation
    def self.included(base)
      base.extend(self)
    end

    # Override Interactor before hooks to ensure
    # that the needs_context before hook is
    # executed last. This will allow us to
    # set required context keys in an interactor
    # before hook without raising a needs_context
    # error.
    def before(*hooks, &block)
      before_hooks.unshift block if block
      hooks.each { |h| before_hooks.unshift h }
    end

    def needs_context(*args)
      before_hooks.push -> {
        missing_context = args - context.to_h.keys.map(&:to_sym)
        missing_keys =  missing_context.reduce([]) do |reduced, key|
          reduced << key
          reduced
        end

        raise "Missing context: #{missing_keys.join(', ')} in #{self}" if missing_keys.any?
      }
    end
  end
end
