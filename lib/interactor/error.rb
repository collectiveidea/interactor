module Interactor
  # Internal: Error raised during Interactor::Context failure. The error stores
  # a copy of the failed context for debugging purposes.
  class Failure < StandardError
    # Internal: Gets the Interactor::Context of the Interactor::Failure
    # instance.
    attr_reader :context

    # Internal: Initialize an Interactor::Failure.
    #
    # context - An Interactor::Context to be stored within the
    #           Interactor::Failure instance. (default: nil)
    #
    # Examples
    #
    #   Interactor::Failure.new
    #   # => #<Interactor::Failure: Interactor::Failure>
    #
    #   context = Interactor::Context.new(foo: "bar")
    #   # => #<Interactor::Context foo="bar">
    #   Interactor::Failure.new(context)
    #   # => #<Interactor::Failure: #<Interactor::Context foo="bar">>
    #
    #   raise Interactor::Failure, context
    #   # => Interactor::Failure: #<Interactor::Context foo="bar">
    def initialize(context = nil)
      @context = context
      super
    end
  end

  class ContractViolation < StandardError

    attr_reader :context, :property

    def initialize(context=nil, opts={})
      @context = context
      @property = opts[:property]
      @message = opts[:message]
      super()
    end

    def message
      @message || "Property '#{property}' violated the interactor's contract."
    end
  end
end
