# Interactor

[![Gem Version](https://img.shields.io/gem/v/interactor.svg)](http://rubygems.org/gems/interactor)
[![Build Status](https://github.com/collectiveidea/interactor/actions/workflows/tests.yml/badge.svg)](https://github.com/collectiveidea/interactor/actions/workflows/tests.yml)
[![Maintainability](https://img.shields.io/codeclimate/maintainability/collectiveidea/interactor.svg)](https://codeclimate.com/github/collectiveidea/interactor)
[![Test Coverage](https://img.shields.io/codeclimate/coverage-letter/collectiveidea/interactor.svg)](https://codeclimate.com/github/collectiveidea/interactor)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)

## Getting Started

Add Interactor to your Gemfile and `bundle install`.

```ruby
gem "interactor", "~> 3.0"
```

## What is an Interactor?

An interactor is a simple, single-purpose object.

Interactors are used to encapsulate your application's
[business logic](http://en.wikipedia.org/wiki/Business_logic). Each interactor
represents one thing that your application *does*.

### Context

An interactor is given a *context*. The context contains everything the
interactor needs to do its work.

When an interactor does its single purpose, it affects its given context.

#### Adding to the Context

As an interactor runs it can add information to the context.

```ruby
context.user = user
```

#### Failing the Context

When something goes wrong in your interactor, you can flag the context as
failed.

```ruby
context.fail!
```

When given a hash argument, the `fail!` method can also update the context. The
following are equivalent:

```ruby
context.error = "Boom!"
context.fail!
```

```ruby
context.fail!(error: "Boom!")
```

You can ask a context if it's a failure:

```ruby
context.failure? # => false
context.fail!
context.failure? # => true
```

or if it's a success.

```ruby
context.success? # => true
context.fail!
context.success? # => false
```

#### Dealing with Failure

`context.fail!` always throws an exception of type `Interactor::Failure`.

Normally, however, these exceptions are not seen. In the recommended usage, the controller invokes the interactor using the class method `call`, then checks the `success?` method of the context.

This works because the `call` class method swallows exceptions.  When unit testing an interactor, if calling custom business logic methods directly and bypassing `call`, be aware that `fail!` will generate such exceptions.

See *Interactors in the Controller*, below, for the recommended usage of `call` and `success?`.

### Hooks

#### Before Hooks

Sometimes an interactor needs to prepare its context before the interactor is
even run. This can be done with before hooks on the interactor.

```ruby
before do
  context.emails_sent = 0
end
```

A symbol argument can also be given, rather than a block.

```ruby
before :zero_emails_sent

def zero_emails_sent
  context.emails_sent = 0
end
```

#### After Hooks

Interactors can also perform teardown operations after the interactor instance
is run.

```ruby
after do
  context.user.reload
end
```

NB: After hooks are only run on success.  If the `fail!` method is called, the interactor's after hooks are not run.

#### Around Hooks

You can also define around hooks in the same way as before or after hooks, using
either a block or a symbol method name. The difference is that an around block
or method accepts a single argument. Invoking the `call` method on that argument
will continue invocation of the interactor. For example, with a block:

```ruby
around do |interactor|
  context.start_time = Time.now
  interactor.call
  context.finish_time = Time.now
end
```

With a method:

```ruby
around :time_execution

def time_execution(interactor)
  context.start_time = Time.now
  interactor.call
  context.finish_time = Time.now
end
```

NB: If the `fail!` method is called, all of the interactor's around hooks cease execution, and no code after `interactor.call` will be run.

#### Hook Sequence

Before hooks are invoked in the order in which they were defined while after
hooks are invoked in the opposite order. Around hooks are invoked outside of any
defined before and after hooks. For example:

```ruby
around do |interactor|
  puts "around before 1"
  interactor.call
  puts "around after 1"
end

around do |interactor|
  puts "around before 2"
  interactor.call
  puts "around after 2"
end

before do
  puts "before 1"
end

before do
  puts "before 2"
end

after do
  puts "after 1"
end

after do
  puts "after 2"
end
```

will output:

```
around before 1
around before 2
before 1
before 2
after 2
after 1
around after 2
around after 1
```

#### Ensure Hooks

Sometimes an interactor needs to perform an action even if the context fails like the
typical begin ensure block.

```ruby
ensure_do do
  context.finish_time = Time.now
end
```

A symbol argument can also be given, rather than a block.

```ruby
ensure_do :set_finish_time

def set_finish_time
  context.finish_time = Time.now
end
```

#### Interactor Concerns

An interactor can define multiple before/after hooks, allowing common hooks to
be extracted into interactor concerns.

```ruby
module InteractorTimer
  extend ActiveSupport::Concern

  included do
    around do |interactor|
      context.start_time = Time.now
      interactor.call
      context.finish_time = Time.now
    end
  end
end
```

### An Example Interactor

Your application could use an interactor to authenticate a user.

```ruby
class AuthenticateUser
  include Interactor

  def call
    if user = User.authenticate(context.email, context.password)
      context.user = user
      context.token = user.secret_token
    else
      context.fail!(message: "authenticate_user.failure")
    end
  end
end
```

To define an interactor, simply create a class that includes the `Interactor`
module and give it a `call` instance method. The interactor can access its
`context` from within `call`.

## Interactors in the Controller

Most of the time, your application will use its interactors from its
controllers. The following controller:

```ruby
class SessionsController < ApplicationController
  def create
    if user = User.authenticate(session_params[:email], session_params[:password])
      session[:user_token] = user.secret_token
      redirect_to user
    else
      flash.now[:message] = "Please try again."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end
end
```

can be refactored to:

```ruby
class SessionsController < ApplicationController
  def create
    result = AuthenticateUser.call(session_params)

    if result.success?
      session[:user_token] = result.token
      redirect_to result.user
    else
      flash.now[:message] = t(result.message)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end
end
```

The `call` class method is the proper way to invoke an interactor. The hash
argument is converted to the interactor instance's context. The `call` instance
method is invoked along with any hooks that the interactor might define.
Finally, the context (along with any changes made to it) is returned.

## When to Use an Interactor

Given the user authentication example, your controller may look like:

```ruby
class SessionsController < ApplicationController
  def create
    result = AuthenticateUser.call(session_params)

    if result.success?
      session[:user_token] = result.token
      redirect_to result.user
    else
      flash.now[:message] = t(result.message)
      render :new
    end
  end

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end
end
```

For such a simple use case, using an interactor can actually require *more*
code. So why use an interactor?

### Clarity

[We](http://collectiveidea.com) often use interactors right off the bat for all
of our destructive actions (`POST`, `PUT` and `DELETE` requests) and since we
put our interactors in `app/interactors`, a glance at that directory gives any
developer a quick understanding of everything the application *does*.

```
▾ app/
  ▸ controllers/
  ▸ helpers/
  ▾ interactors/
      authenticate_user.rb
      cancel_account.rb
      publish_post.rb
      register_user.rb
      remove_post.rb
  ▸ mailers/
  ▸ models/
  ▸ views/
```

**TIP:** Name your interactors after your business logic, not your
implementation. `CancelAccount` will serve you better than `DestroyUser` as the
account cancellation interaction takes on more responsibility in the future.

### The Future™

**SPOILER ALERT:** Your use case won't *stay* so simple.

In [our](http://collectiveidea.com) experience, a simple task like
authenticating a user will eventually take on multiple responsibilities:

* Welcoming back a user who hadn't logged in for a while
* Prompting a user to update his or her password
* Locking out a user in the case of too many failed attempts
* Sending the lock-out email notification

The list goes on, and as that list grows, so does your controller. This is how
fat controllers are born.

If instead you use an interactor right away, as responsibilities are added, your
controller (and its tests) change very little or not at all. Choosing the right
kind of interactor can also prevent simply shifting those added responsibilities
to the interactor.

## Kinds of Interactors

There are two kinds of interactors built into the Interactor library: basic
interactors and organizers.

### Interactors

A basic interactor is a class that includes `Interactor` and defines `call`.

```ruby
class AuthenticateUser
  include Interactor

  def call
    if user = User.authenticate(context.email, context.password)
      context.user = user
      context.token = user.secret_token
    else
      context.fail!(message: "authenticate_user.failure")
    end
  end
end
```

Basic interactors are the building blocks. They are your application's
single-purpose units of work.

### Organizers

An organizer is an important variation on the basic interactor. Its single
purpose is to run *other* interactors.

```ruby
class PlaceOrder
  include Interactor::Organizer

  organize CreateOrder, ChargeCard

  ensure_do SendThankYou
end
```

In the controller, you can run the `PlaceOrder` organizer just like you would
any other interactor:

```ruby
class OrdersController < ApplicationController
  def create
    result = PlaceOrder.call(order_params: order_params)

    if result.success?
      redirect_to result.order
    else
      @order = result.order
      render :new
    end
  end

  private

  def order_params
    params.require(:order).permit!
  end
end
```

The organizer passes its context to the interactors that it organizes, one at a
time and in order. Each interactor may change that context before it's passed
along to the next interactor.

#### Rollback

If any one of the organized interactors fails its context, the organizer stops.
If the `ChargeCard` interactor fails, `SendThankYou` is never called.

In addition, any interactors that had already run are given the chance to undo
themselves, in reverse order. Simply define the `rollback` method on your
interactors:

```ruby
class CreateOrder
  include Interactor

  def call
    order = Order.create(order_params)

    if order.persisted?
      context.order = order
    else
      context.fail!
    end
  end

  def rollback
    context.order.destroy
  end
end
```

**NOTE:** The interactor that fails is *not* rolled back. Because every
interactor should have a single purpose, there should be no need to clean up
after any failed interactor.

## Testing Interactors

When written correctly, an interactor is easy to test because it only *does* one
thing. Take the following interactor:

```ruby
class AuthenticateUser
  include Interactor

  def call
    if user = User.authenticate(context.email, context.password)
      context.user = user
      context.token = user.secret_token
    else
      context.fail!(message: "authenticate_user.failure")
    end
  end
end
```

You can test just this interactor's single purpose and how it affects the
context.

```ruby
describe AuthenticateUser do
  subject(:context) { AuthenticateUser.call(email: "john@example.com", password: "secret") }

  describe ".call" do
    context "when given valid credentials" do
      let(:user) { double(:user, secret_token: "token") }

      before do
        allow(User).to receive(:authenticate).with("john@example.com", "secret").and_return(user)
      end

      it "succeeds" do
        expect(context).to be_a_success
      end

      it "provides the user" do
        expect(context.user).to eq(user)
      end

      it "provides the user's secret token" do
        expect(context.token).to eq("token")
      end
    end

    context "when given invalid credentials" do
      before do
        allow(User).to receive(:authenticate).with("john@example.com", "secret").and_return(nil)
      end

      it "fails" do
        expect(context).to be_a_failure
      end

      it "provides a failure message" do
        expect(context.message).to be_present
      end
    end
  end
end
```

[We](http://collectiveidea.com) use RSpec but the same approach applies to any
testing framework.

### Isolation

You may notice that we stub `User.authenticate` in our test rather than creating
users in the database. That's because our purpose in
`spec/interactors/authenticate_user_spec.rb` is to test just the
`AuthenticateUser` interactor. The `User.authenticate` method is put through its
own paces in `spec/models/user_spec.rb`.

It's a good idea to define your own interfaces to your models. Doing so makes it
easy to draw a line between which responsibilities belong to the interactor and
which to the model. The `User.authenticate` method is a good, clear line.
Imagine the interactor otherwise:

```ruby
class AuthenticateUser
  include Interactor

  def call
    user = User.where(email: context.email).first

    # Yuck!
    if user && BCrypt::Password.new(user.password_digest) == context.password
      context.user = user
    else
      context.fail!(message: "authenticate_user.failure")
    end
  end
end
```

It would be very difficult to test this interactor in isolation and even if you
did, as soon as you change your ORM or your encryption algorithm (both model
concerns), your interactors (business concerns) break.

*Draw clear lines.*

### Integration

While it's important to test your interactors in isolation, it's just as
important to write good integration or acceptance tests.

One of the pitfalls of testing in isolation is that when you stub a method, you
could be hiding the fact that the method is broken, has changed or doesn't even
exist.

When you write full-stack tests that tie all of the pieces together, you can be
sure that your application's individual pieces are working together as expected.
That becomes even more important when you add a new layer to your code like
interactors.

**TIP:** If you track your test coverage, try for 100% coverage *before*
integrations tests. Then keep writing integration tests until you sleep well at
night.

### Controllers

One of the advantages of using interactors is how much they simplify controllers
and their tests. Because you're testing your interactors thoroughly in isolation
as well as in integration tests (right?), you can remove your business logic
from your controller tests.

```ruby
class SessionsController < ApplicationController
  def create
    result = AuthenticateUser.call(session_params)

    if result.success?
      session[:user_token] = result.token
      redirect_to result.user
    else
      flash.now[:message] = t(result.message)
      render :new
    end
  end

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end
end
```

```ruby
describe SessionsController do
  describe "#create" do
    before do
      expect(AuthenticateUser).to receive(:call).once.with(email: "john@doe.com", password: "secret").and_return(context)
    end

    context "when successful" do
      let(:user) { double(:user, id: 1) }
      let(:context) { double(:context, success?: true, user: user, token: "token") }

      it "saves the user's secret token in the session" do
        expect {
          post :create, session: { email: "john@doe.com", password: "secret" }
        }.to change {
          session[:user_token]
        }.from(nil).to("token")
      end

      it "redirects to the homepage" do
        response = post :create, session: { email: "john@doe.com", password: "secret" }

        expect(response).to redirect_to(user_path(user))
      end
    end

    context "when unsuccessful" do
      let(:context) { double(:context, success?: false, message: "message") }

      it "sets a flash message" do
        expect {
          post :create, session: { email: "john@doe.com", password: "secret" }
        }.to change {
          flash[:message]
        }.from(nil).to(I18n.translate("message"))
      end

      it "renders the login form" do
        response = post :create, session: { email: "john@doe.com", password: "secret" }

        expect(response).to render_template(:new)
      end
    end
  end
end
```

This controller test will have to change very little during the life of the
application because all of the magic happens in the interactor.

### Rails

[We](http://collectiveidea.com) love Rails, and we use Interactor with Rails. We
put our interactors in `app/interactors` and we name them as verbs:

* `AddProductToCart`
* `AuthenticateUser`
* `PlaceOrder`
* `RegisterUser`
* `RemoveProductFromCart`

See: [Interactor Rails](https://github.com/collectiveidea/interactor-rails)

## Contributions

Interactor is open source and contributions from the community are encouraged!
No contribution is too small.

See Interactor's
[contribution guidelines](CONTRIBUTING.md) for more information.

## Thank You

A very special thank you to [Attila Domokos](https://github.com/adomokos) for
his fantastic work on [LightService](https://github.com/adomokos/light-service).
Interactor is inspired heavily by the concepts put to code by Attila.

Interactor was born from a desire for a slightly simplified interface. We
understand that this is a matter of personal preference, so please take a look
at LightService as well!
