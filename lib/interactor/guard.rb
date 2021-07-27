# frozen_string_literal: true

module Interactor
  # Internal: Methods relating to supporting hooks around Interactor invocation.
  module Guard
    # Guard that each param is present in the context
    #
    # @param [Array<Symbol>] *params List of paramater names to check
    def guard(*params, with_context: nil, message: nil)
      ctx = grab_context(with_context)

      params.each do |param|
        if ctx[param].nil?
          if message.nil?
            puts "#{self.class.name} - Missing #{param} parameter in context"
            ctx.fail!(message: 'Command failed')
          end
          
          puts message
          ctx.fail!(message: message)
        end
      end
    end
    # alias guard_all guard

    def guard_any(*params, with_context: nil)
      ctx = grab_context(with_context)

      return params.any? { |param| !ctx[param].nil? }

      puts "#{self.class.name} - At least one of the following parameters is required: #{params.join(', ')}"
      
      ctx.fail!(message: 'Command failed')
    end

    def ensure_one(*params, with_context: nil)
      the_context = get_context(with_context)
  
      if params.all? { |param| the_context[param].nil? }
        Rails.logger.error(
          "#{self.class.name}# Requires at least one of the following parameters: " \
          "#{params.join(',')} in the context"
        )
        the_context.fail!(message: 'Command failed')
      end
    end

    private

    def grab_context(with_context)
      unless defined?(context) || with_context.present?
        raise ArgumentError, "neither in-scope 'context' nor 'with_context' override param found"
      end

      # Usually we grab context in scope because of Interactor (commands),
      # so let's ensure our 'override' context behaves similarly.
      Interactor::Context.build(with_context || context)
    end
  end
end