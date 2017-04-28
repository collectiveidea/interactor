require "ostruct"

module Interactor
  # Public: The object for tracking state of an Interactor's invocation. The
  # context is used to initialize the interactor with the information required
  # for invocation. The interactor manipulates the context to produce the result
  # of invocation.
  #
  # The context is the mechanism by which success and failure are determined and
  # the context is responsible for tracking individual interactor invocations
  # for the purpose of rollback.
  #
  # The context may be manipulated using arbitrary getter and setter methods.
  #
  # Examples
  #
  #   context = Interactor::Context.new
  #   # => #<Interactor::Context>
  #   context.foo = "bar"
  #   # => "bar"
  #   context
  #   # => #<Interactor::Context foo="bar">
  #   context.hello = "world"
  #   # => "world"
  #   context
  #   # => #<Interactor::Context foo="bar" hello="world">
  #   context.foo = "baz"
  #   # => "baz"
  #   context
  #   # => #<Interactor::Context foo="baz" hello="world">
  class Context < OpenStruct
    # Internal: Initialize an Interactor::Context or preserve an existing one.
    # If the argument given is an Interactor::Context, the argument is returned.
    # Otherwise, a new Interactor::Context is initialized from the provided
    # hash.
    #
    # The "build" method is used during interactor initialization.
    #
    # context - A Hash whose key/value pairs are used in initializing a new
    #           Interactor::Context object. If an existing Interactor::Context
    #           is given, it is simply returned. (default: {})
    #
    # Examples
    #
    #   context = Interactor::Context.build(foo: "bar")
    #   # => #<Interactor::Context foo="bar">
    #   context.object_id
    #   # => 2170969340
    #   context = Interactor::Context.build(context)
    #   # => #<Interactor::Context foo="bar">
    #   context.object_id
    #   # => 2170969340
    #
    # Returns the Interactor::Context.
    def self.build(context = {})
      context.is_a?(Context) ? context : new(context)
    end

    # Public: Whether the Interactor::Context is successful. By default, a new
    # context is successful and only changes when explicitly failed.
    #
    # The "success?" method is the inverse of the "failure?" method.
    #
    # Examples
    #
    #   context = Interactor::Context.new
    #   # => #<Interactor::Context>
    #   context.success?
    #   # => true
    #   context.fail!
    #   # => Interactor::Failure: #<Interactor::Context>
    #   context.success?
    #   # => false
    #
    # Returns true by default or false if failed.
    def success?
      !failure?
    end

    # Public: Whether the Interactor::Context has failed. By default, a new
    # context is successful and only changes when explicitly failed.
    #
    # The "failure?" method is the inverse of the "success?" method.
    #
    # Examples
    #
    #   context = Interactor::Context.new
    #   # => #<Interactor::Context>
    #   context.failure?
    #   # => false
    #   context.fail!
    #   # => Interactor::Failure: #<Interactor::Context>
    #   context.failure?
    #   # => true
    #
    # Returns false by default or true if failed.
    def failure?
      @failure || false
    end

    # Public: Fail the Interactor::Context. Failing a context throws a "tag"
    # that will only be caught by the originally called interactor. This allows
    # execution to exit quickly, even from deeply nested interactor executions.
    # If the context is failed outside the expected scenario of a calling
    # interactor, nothing is thrown.
    #
    # The context is also flagged as having failed.
    #
    # Optionally the caller may provide a hash of key/value pairs to be merged
    # into the context before failure.
    #
    # context - A Hash whose key/value pairs are merged into the existing
    #           Interactor::Context instance. (default: {})
    #
    # Examples
    #
    #   context = Interactor::Context.new
    #   # => #<Interactor::Context>
    #   context.fail!
    #   # => Interactor::Failure: #<Interactor::Context>
    #   context.fail! rescue false
    #   # => false
    #   context.fail!(foo: "baz")
    #   # => Interactor::Failure: #<Interactor::Context foo="baz">
    #
    # Returns nothing.
    # Throws the originally called interactor if present.
    def fail!(context = {})
      context.each { |key, value| self[key] = value }
      @failure = true
      throw!
    end

    # Internal: Throw the originally called Interactor instance. This is used
    # by the Interactor::Context#fail! method.
    #
    # Returns nothing.
    # Throws an Interactor instance if possible.
    def throw!
      interactor = _calling.first
      throw interactor if interactor
    end

    # Public: Raise an Interactor::Failure providing the current context as a
    # payload. This is called upon completion of Interactor#run! if the context
    # has failed.
    #
    # Raises Interactor::Failure.
    def raise!
      raise Failure, self
    end

    # Internal: Track that an Interactor is being called. The "calling!" method
    # is used by the interactor being invoked with this context. Before an
    # interactor is called, the interactor instance is tracked in the context
    # for the purpose of determining the originally called interactor. Knowing
    # the originally called interactor allows the context to throw in such a way
    # that only the originally called interactor will catch.
    #
    # The required block is executed and any throw as a result of context
    # failure will be caught if the interactor given is the first interactor
    # being called, making it the originally called interactor.
    #
    # interactor - An Interactor instance that will be called.
    #
    # Returns nothing.
    def calling!(interactor)
      _calling << interactor

      catch interactor do
        yield
        return
      end

      # This line is only reached if a failure is thrown that is caught by the
      # catch block above. This ensures that only the originally called
      # interactor will attempt to roll back.
      rollback!
    rescue
      # TODO: Rollback will no-op if called multiple times. Still, for a deeply
      # nested interactor that raises an error, the rollback below will be
      # attempted once for every level of nesting. Ideally, only the originally
      # called interactor will attempt the rollback.
      rollback!
      raise
    end

    # Internal: Track that an Interactor has been called. The "called!" method
    # is used by the interactor being invoked with this context. After an
    # interactor is successfully called, the interactor instance is tracked in
    # the context for the purpose of potential future rollback.
    #
    # interactor - An Interactor instance that has been successfully called.
    #
    # Returns nothing.
    def called!(interactor)
      _called << interactor
    end

    # Public: Roll back the Interactor::Context. Any interactors to which this
    # context has been passed and which have been successfully called are asked
    # to roll themselves back by invoking their "rollback" instance methods.
    #
    # Examples
    #
    #   context = MyInteractor.call(foo: "bar")
    #   # => #<Interactor::Context foo="baz">
    #   context.rollback!
    #   # => true
    #   context
    #   # => #<Interactor::Context foo="bar">
    #
    # Returns true if rolled back successfully or false if already rolled back.
    def rollback!
      return false if @rolled_back
      _called.reverse_each(&:rollback)
      @rolled_back = true
    end

    # Public: Check for the presence of a given key in the context. This does
    # not check whether the value is truthy, just whether the key is set to any
    # value at all.
    #
    # Returns true if the key is found or false otherwise.
    def include?(key)
      table.include?(key.to_sym)
    end

    # Internal: An Array of Interactor instances that have begun execution
    # against this Interactor::Context instance.
    #
    # Examples
    #
    #   context = Interactor::Context.new
    #   # => #<Interactor::Context>
    #   context._calling
    #   # => []
    #
    #   context = MyInteractor.call(foo: "bar")
    #   # => #<Interactor::Context foo="baz">
    #   context.calling
    #   # => [#<MyInteractor @context=#<Interactor::Context foo="baz">>]
    #
    # Returns an Array of Interactor instances or an empty Array.
    def _calling
      @calling ||= []
    end

    # Internal: An Array of successfully called Interactor instances invoked
    # against this Interactor::Context instance.
    #
    # Examples
    #
    #   context = Interactor::Context.new
    #   # => #<Interactor::Context>
    #   context._called
    #   # => []
    #
    #   context = MyInteractor.call(foo: "bar")
    #   # => #<Interactor::Context foo="baz">
    #   context._called
    #   # => [#<MyInteractor @context=#<Interactor::Context foo="baz">>]
    #
    # Returns an Array of Interactor instances or an empty Array.
    def _called
      @called ||= []
    end
  end
end
