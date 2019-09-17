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

      # Internal: Expose instance variables of Interactor instance metaclass
      # for reading.
      class << self
        attr_reader :exception_classes
        attr_reader :exception_handlers
      end
      # Public: Gets the Interactor::Context of the Interactor instance.
      attr_reader :context
    end
  end

  # Internal: Interactor class methods.
  module ClassMethods
    # Public: Specify exception classes that should result in failing context
    # and provide a custom logic on rescued exception before failing. Failing
    # the context is raising Interactor::Failure, this exception is silently
    # swallowed by the interactor. Note that any code after failing the context
    # will not be evaluated.
    #
    # Examples
    #   class MyInteractor
    #     include Interactor
    #
    #     fail_on_exception StandardErro
    #     fail_on_exception NameError, NoMethodError
    #
    #     exception_handler = ->(e) { ErrorLogger.log(e) }
    #
    #     fail_on_exception MyBespokeError, exception_handler: exception_handler
    #
    #     def call
    #       exception_raising_logic
    #     end
    #   end
    #
    #   MyInteractor.call
    #   # => #<Interactor::Context error=#<NameError: undefined local variable
    #   or method `method_raising_exception' for
    #   #<MyInteractor:0x0000000003d17330> Did you mean?  method_missing>>
    #
    #   MyInteractor.call.success?
    #   # => false
    #
    #   Returned context holds the rescued exception object
    #
    #   MyInteractor.call.error.class.name
    #   # => "NameError"
    #
    #   Method accepts object representing exception classes of any type that
    #   will respond to #to_s and return string, as an argument to
    #   Kernel.const_get will result in previously initialized constant.
    #   e.g. constant, symbol, string...

    def fail_on_exception(*exceptions_to_fail_on, exception_handler: ->(e) {})
      exceptions_to_fail_on = exceptions_to_fail_on.each do |it|
        Kernel.const_get(it.to_s)
      end
      @exception_classes = Array(exception_classes) | exceptions_to_fail_on
      return unless exception_handler
      exceptions_to_fail_on.each do |exception_class|
        @exception_handlers = Hash(exception_handlers).update(
          exception_class.name.to_sym => exception_handler
        )
      end
    end

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

  # Internal: Invoke an interactor instance along with all defined hooks. The
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
    run!
  rescue Failure
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
    with_hooks do
      begin
        call
        context.called!(self)
      rescue *self.class.exception_classes => e
        self.class.exception_handlers[e.class.name.to_sym]&.call(e)
        context.fail!(error: e)
      end
    end
  rescue
    context.rollback!
    raise
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
end
