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

  class ContractError < StandardError
    attr_reader :context

    def initialize(context=nil, opts={})
      @context = context
      @message = opts[:message]
      @undeclared_properties = opts[:undeclared] || []
      @missing_properties = opts[:missing] || []
      super()
    end

    def message
      @message || "#{missing_message} #{undeclared_message}".strip
    end

    private
    
    def missing_message
      return unless @missing_properties.any?
      insert = error_inserts(@missing_properties)
      "Expected interactor to be called with #{insert[:term]} #{insert[:list]}."
    end

    def undeclared_message
      return unless @undeclared_properties.any?
      insert = error_inserts(@undeclared_properties)
      "Called with undeclared #{insert[:term]} #{insert[:list]}."
    end

    def error_inserts(property_list)
      if property_list.size > 1
        term = "properties"
        list = property_list.map {|p| "'#{p}'" }.join(', ')
      else
        term, list = "property", "'#{property_list.first}'"
      end

      { term: term, list: list}
    end
  end
end
