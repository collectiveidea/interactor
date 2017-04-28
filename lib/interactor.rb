require "interactor/context"
require "interactor/error"
require "interactor/hooks"
require "interactor/organizer"

# Public: Interactor methods. Because Interactor is a module, custom Interactor
# classes should include Interactor rather than inherit from it.
#
# Examples
#
#   class MyInteractor
#     include Interactor
#
#     def call
#       puts context.foo
#     end
#   end
module Interactor
  # Internal: Install Interactor's behavior in the given class.
  def self.included(base)
    base.class_eval do
      extend ClassMethods
      include Hooks

      # Public: Gets the Interactor::Context of the Interactor instance.
      attr_reader :context
    end
  end

  # Internal: Interactor class methods.
  module ClassMethods
    # Public: Invoke an Interactor. This is the primary public API method to an
    # interactor.
    #
    # context - A Hash whose key/value pairs are used in initializing a new
    #           Interactor::Context object. An existing Interactor::Context may
    #           also be given. (default: {})
    #
    # Examples
    #
    #   MyInteractor.call(foo: "bar")
    #   # => #<Interactor::Context foo="bar">
    #
    #   MyInteractor.call
    #   # => #<Interactor::Context>
    #
    # Returns the resulting Interactor::Context after manipulation by the
    #   interactor.
    def call(context = {})
      new(context).tap(&:run).context
    end

    # Public: Invoke an Interactor. The "call!" method behaves identically to
    # the "call" method with one notable exception. If the context is failed
    # during invocation of the interactor, the Interactor::Failure is raised.
    #
    # context - A Hash whose key/value pairs are used in initializing a new
    #           Interactor::Context object. An existing Interactor::Context may
    #           also be given. (default: {})
    #
    # Examples
    #
    #   MyInteractor.call!(foo: "bar")
    #   # => #<Interactor::Context foo="bar">
    #
    #   MyInteractor.call!
    #   # => #<Interactor::Context>
    #
    #   MyInteractor.call!(foo: "baz")
    #   # => Interactor::Failure: #<Interactor::Context foo="baz">
    #
    # Returns the resulting Interactor::Context after manipulation by the
    #   interactor.
    # Raises Interactor::Failure if the context is failed.
    def call!(context = {})
      new(context).tap(&:run!).context
    end
  end

  # Internal: Initialize an Interactor.
  #
  # context - A Hash whose key/value pairs are used in initializing the
  #           interactor's context. An existing Interactor::Context may also be
  #           given. (default: {})
  #
  # Examples
  #
  #   MyInteractor.new(foo: "bar")
  #   # => #<MyInteractor @context=#<Interactor::Context foo="bar">>
  #
  #   MyInteractor.new
  #   # => #<MyInteractor @context=#<Interactor::Context>>
  def initialize(context = {})
    @context = Context.build(context)
  end

  # Internal: Invoke an Interactor instance along with all defined hooks. The
  # "run" method is used internally by the "call" class method. The following
  # are equivalent:
  #
  #   MyInteractor.call(foo: "bar")
  #   # => #<Interactor::Context foo="bar">
  #
  #   interactor = MyInteractor.new(foo: "bar")
  #   interactor.run
  #   interactor.context
  #   # => #<Interactor::Context foo="bar">
  #
  # After successful invocation of the interactor, the instance is tracked
  # within the context. If the context is failed or any error is raised, the
  # context is rolled back.
  #
  # Returns nothing.
  def run
    context.calling!(self) do
      with_hooks do
        call(*arguments_for_call)
        context.called!(self)
      end
    end
  end

  # Internal: Invoke an Interactor instance along with all defined hooks. The
  # "run!" method is used internally by the "call!" class method. The following
  # are equivalent:
  #
  #   MyInteractor.call!(foo: "bar")
  #   # => #<Interactor::Context foo="bar">
  #
  #   interactor = MyInteractor.new(foo: "bar")
  #   interactor.run!
  #   interactor.context
  #   # => #<Interactor::Context foo="bar">
  #
  # After successful invocation of the interactor, the instance is tracked
  # within the context. If the context is failed or any error is raised, the
  # context is rolled back.
  #
  # The "run!" method behaves identically to the "run" method with one notable
  # exception. If the context is failed during invocation of the interactor,
  # the Interactor::Failure is raised.
  #
  # Returns nothing.
  # Raises Interactor::Failure if the context is failed.
  def run!
    run
    context.raise! if context.failure?
  end

  # Public: Invoke an Interactor instance without any hooks, tracking, or
  # rollback. It is expected that the "call" instance method is overwritten for
  # each interactor class.
  #
  # Returns nothing.
  def call
  end

  # Public: Reverse prior invocation of an Interactor instance. Any interactor
  # class that requires undoing upon downstream failure is expected to overwrite
  # the "rollback" instance method.
  #
  # Returns nothing.
  def rollback
  end

  private

  # Internal: Determine what keyword arguments (if any) should be passed to the
  # "call" instance method when invoking an Interactor. The "call" instance
  # method may accept any number of keyword arguments. This method will extract
  # values from the context in order to populate those arguments based on their
  # names.
  #
  # Returns an Array of arguments to be applied as an argument list.
  def arguments_for_call
    positional_arguments = []
    keyword_arguments = {}

    method(:call).parameters.each do |(type, name)|
      next unless type == :keyreq || type == :key
      next unless context.include?(name)

      keyword_arguments[name] = context[name]
    end

    positional_arguments << keyword_arguments if keyword_arguments.any?
    positional_arguments
  end
end
