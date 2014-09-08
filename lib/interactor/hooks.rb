module Interactor
  # Internal: Methods relating to supporting hooks around Interactor invocation.
  module Hooks
    # Internal: Install Interactor's behavior in the given class.
    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end

    # Internal: Interactor::Hooks class methods.
    module ClassMethods
      # Public: Declare hooks to run before Interactor invocation. The before
      # method may be called multiple times; subsequent calls append declared
      # hooks to existing before hooks.
      #
      # hooks - Zero or more Symbol method names representing instance methods
      #         to be called before interactor invocation.
      # block - An optional block to be executed as a hook. If given, the block
      #         is executed after methods corresponding to any given Symbols.
      #
      # Examples
      #
      #   class MyInteractor
      #     include Interactor
      #
      #     before :set_start_time
      #
      #     before do
      #       puts "started"
      #     end
      #
      #     def call
      #       puts "called"
      #     end
      #
      #     private
      #
      #     def set_start_time
      #       context.start_time = Time.now
      #     end
      #   end
      #
      # Returns nothing.
      def before(*hooks, &block)
        hooks << block if block
        hooks.each { |hook| before_hooks.push(hook) }
      end

      # Public: Declare hooks to run after Interactor invocation. The after
      # method may be called multiple times; subsequent calls prepend declared
      # hooks to existing after hooks.
      #
      # hooks - Zero or more Symbol method names representing instance methods
      #         to be called after interactor invocation.
      # block - An optional block to be executed as a hook. If given, the block
      #         is executed before methods corresponding to any given Symbols.
      #
      # Examples
      #
      #   class MyInteractor
      #     include Interactor
      #
      #     after :set_finish_time
      #
      #     after do
      #       puts "finished"
      #     end
      #
      #     def call
      #       puts "called"
      #     end
      #
      #     private
      #
      #     def set_finish_time
      #       context.finish_time = Time.now
      #     end
      #   end
      #
      # Returns nothing.
      def after(*hooks, &block)
        hooks << block if block
        hooks.each { |hook| after_hooks.unshift(hook) }
      end

      # Internal: An Array of declared hooks to run before Interactor
      # invocation. The hooks appear in the order in which they will be run.
      #
      # Examples
      #
      #   class MyInteractor
      #     include Interactor
      #
      #     before :set_start_time, :say_hello
      #   end
      #
      #   MyInteractor.before_hooks
      #   # => [:set_start_time, :say_hello]
      #
      # Returns an Array of Symbols and Procs.
      def before_hooks
        @before_hooks ||= []
      end

      # Internal: An Array of declared hooks to run before Interactor
      # invocation. The hooks appear in the order in which they will be run.
      #
      # Examples
      #
      #   class MyInteractor
      #     include Interactor
      #
      #     after :set_finish_time, :say_goodbye
      #   end
      #
      #   MyInteractor.after_hooks
      #   # => [:say_goodbye, :set_finish_time]
      #
      # Returns an Array of Symbols and Procs.
      def after_hooks
        @after_hooks ||= []
      end
    end

    private

    # Internal: Run before and after hooks around yielded execution. The
    # required block is surrounded with hooks and executed.
    #
    # Examples
    #
    #   class MyProcessor
    #     include Interactor::Hooks
    #
    #     def process_with_hooks
    #       with_hooks do
    #         process
    #       end
    #     end
    #
    #     def process
    #       puts "processed!"
    #     end
    #   end
    #
    # Returns nothing.
    def with_hooks
      run_before_hooks
      yield
      run_after_hooks
    end

    # Internal: Run before hooks.
    #
    # Returns nothing.
    def run_before_hooks
      run_hooks(self.class.before_hooks)
    end

    # Internal: Run after hooks.
    #
    # Returns nothing.
    def run_after_hooks
      run_hooks(self.class.after_hooks)
    end

    # Internal: Run a colection of hooks. The "run_hooks" method is the common
    # interface by which collections of either before or after hooks are run.
    #
    # hooks - An Array of Symbol and Proc hooks.
    #
    # Returns nothing.
    def run_hooks(hooks)
      hooks.each { |hook| run_hook(hook) }
    end

    # Internal: Run an individual hook. The "run_hook" method is the common
    # interface by which an individual hook is run. If the given hook is a
    # symbol, the method is invoked whether public or private. If the hook is a
    # proc, the proc is evaluated in the context of the current instance.
    #
    # hook - A Symbol or Proc hook.
    #
    # Returns nothing.
    def run_hook(hook)
      hook.is_a?(Symbol) ? send(hook) : instance_eval(&hook)
    end
  end
end
