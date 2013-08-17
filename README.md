# Interactor

[![Gem Version](https://badge.fury.io/rb/interactor.png)](http://badge.fury.io/rb/interactor)
[![Build Status](https://travis-ci.org/collectiveidea/interactor.png?branch=master)](https://travis-ci.org/collectiveidea/interactor)
[![Code Climate](https://codeclimate.com/github/collectiveidea/interactor.png)](https://codeclimate.com/github/collectiveidea/interactor)
[![Coverage Status](https://coveralls.io/repos/collectiveidea/interactor/badge.png?branch=master)](https://coveralls.io/r/collectiveidea/interactor?branch=master)
[![Dependency Status](https://gemnasium.com/collectiveidea/interactor.png)](https://gemnasium.com/collectiveidea/interactor)

Interactor provides a common interface for performing complex interactions in a single request.

## Problems

If you're like us at [Collective Idea](http://collectiveidea.com), you've noticed that there seems to be a layer missing between the Controller and the Model.

### Fat Models

We've been told time after time to keep our controllers "skinny" but this usually comes at the expense of our models becoming pretty flabby. Oftentimes, much of the excess weight doesn't belong on the model. We're sending emails, making calls to external services and more, all from the model. It's not right.

*The purpose of the model layer is to be a gatekeeper to the application's data.*

Consider the following model:

```ruby
class User < ActiveRecord::Base
  validates :name, :email, presence: true

  after_create :send_welcome_email

  private

  def send_welcome_email
    Notifier.welcome(self).deliver
  end
end
```

We see this pattern all too often. The problem is that *any* time we want to add a user to the application, the welcome email will be sent. That includes creating users in development and in your tests. Is that really what we want?

Sending a welcome email is business logic. It has nothing to do with the integrity of the application's data, so it belongs somewhere else.

### Fat Controllers

Usually, the alternative to fat models is fat controllers.

While business logic may be more at home in a controller, controllers are typically intermingled with the concept of a request. HTTP requests are complex and that fact makes testing your business logic more difficult than it should be.

*Your business logic should be unaware of your delivery mechanism.*

So what if we encapsulated all of our business logic in dead-simple Ruby. One glance at a directory like `app/interactors` could go a long way in answering the question, "What does this app do?".

```
▸ app/
  ▾ interactors/
    add_product_to_cart.rb
    authenticate_user.rb
    place_order.rb
    register_user.rb
    remove_product_from_cart.rb
```

## Interactors

An interactor is an object with a simple interface and a singular purpose.

Interactors are given a context from the controller and do one thing: perform. When an interactor performs, it may act on models, send emails, make calls to external services and more. The interactor may also modify the given context.

A simple interactor may look like:

```ruby
class AuthenticateUser
  include Interactor

  def perform
    if user = User.authenticate(context[:email], context[:password])
      context[:user] = user
    else
      context.fail!
    end
  end
end
```

There are a few important things to note about this interactor:

1. It's simple.
2. It's just Ruby.
3. It's easily testable.

It's feasible that a collection of small interactors such as these could encapsulate *all* of your business logic.

Interactors free up your controllers to simply accept requests and build responses. They free up your models to acts as the gatekeepers to your data.

## Organizers

An organizer is just an interactor that's in charge of other interactors. When an organizer is asked to perform, it just asks its interactors to perform, in order.

Organizers are great for complex interactions. For example, placing an order might involve:

* checking inventory
* calculating tax
* charging a credit card
* writing an order to the database
* sending email notifications
* scheduling a follow-up email

Each of these actions can (and should) have its own interactor and one organizer can perform them all. That organizer may look like:

```ruby
class PlaceOrder
  include Interactor::Organizer

  organize [
    CheckInventory,
    CalculateTax,
    ChargeCard,
    CreateOrder,
    DeliverThankYou,
    DeliverOrderNotification,
    ScheduleFollowUp
  ]
end
```

Breaking your interactors into bite-sized pieces also gives you the benefit or reusability. In our example above, there may be several scenarios where you may want to check inventory. Encapsulating that logic in one interactor enables you to reuse that interactor, reducing duplication.

## Examples

### Interactors

Take the simple case of authenticating a user.

Using an interactor, the controller stays very clean, making it very readable and easily testable.

```ruby
class SessionsController < ApplicationController
  def create
    result = AuthenticateUser.perform(session_params)

    if result.success?
      redirect_to result.user
    else
      render :new
    end
  end

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end
end
```

The `result` above is an instance of the `AuthenticateUser` interactor that has been performed. The magic happens in the interactor, after receiving a *context* from the controller. A context is just a glorified hash that the interactor manipulates.

```ruby
class AuthenticateUser
  include Interactor

  def perform
    if user = User.authenticate(context[:email], context[:password])
      context[:user] = user
    else
      context.fail!
    end
  end
end
```

The interactor also has convenience methods for dealing with its context. Anything added to the context is available via getter method on the interactor instance. The following is equivalent:

```ruby
class AuthenticateUser
  include Interactor

  def perform
    if user = User.authenticate(email, password)
      context[:user] = user
    else
      fail!
    end
  end
end
```

An interactor can fail with an optional hash that is merged into the context.

```ruby
fail!(message: "Uh oh!")
```

Interactors are successful until explicitly failed. Instances respond to `success?` and `failure?`.

### Organizers

In the example above, one could argue that the interactor is simple enough that it could be excluded altogether. While that's probably true, in [our](http://collectiveidea.com) experience, these interactions don't stay simple for long. When they get more complex, the `AuthenticateUser` interactor can be converted to an organizer.

```ruby
class AuthenticateUser
  include Interactor::Organizer

  organize FindUserByEmailAndPassword, SendWelcomeEmail
end
```

And your controller doesn't change a bit!

The `AuthenticateUser` organizer receives its context from the controller and passes it to the interactors, which each manipulate it in turn.

```ruby
class FindUserByEmailAndPassword
  include Interactor

  def perform
    if user = User.authenticate(email, password)
      context[:user] = user
    else
      fail!
    end
  end
end
```

```ruby
class SendWelcomeEmail
  include Interactor

  def perform
    if user.newly_created?
      Notifier.welcome(user).deliver
      context[:new_user] = true
    end
  end
end
```

#### Inception

Because interactors and organizers adhere to the same interface, it's trivial for an organizer to organize… organizers!

#### Rollback

If an organizer has three interactors and the second one fails, the third one is never called.

In addition to halting the chain, an organizer will also *rollback* through the interactors that it has performed so that the failed interactor and each completed interactor has the opportunity to undo itself. Just define a `rollback` method. It has all the same access to the context as `perform` does.

## Conventions

We love Rails, and we use Interactor with Rails. We put our interactors in `app/interactors` and we name them as verbs:

* `AddProductToCart`
* `AuthenticateUser`
* `PlaceOrder`
* `RegisterUser`
* `RemoveProductFromCart`

See [Interactor Rails](https://github.com/collectiveidea/interactor-rails)

## Contributions

Interactor is open source and contributions from the community are encouraged! No contribution is too small. Please consider:

* adding an awesome feature
* fixing a terrible bug
* updating documentation
* fixing a not-so-bad bug
* fixing typos

For the best chance of having your changes merged, please:

1. Ask us! We'd love to hear what you're up to.
2. Fork the project.
3. Commit your changes and tests (if applicable (they're applicable)).
4. Submit a pull request with a thorough explanation and at least one animated GIF.

## Thanks

A very special thank you to [Attila Domokos](https://github.com/adomokos) for his fantastic work on [LightService](https://github.com/adomokos/light-service). Interactor is inspired heavily by the concepts put to code by Attila.

Interactor was born from a desire for a slightly different (in our minds, simplified) interface. We understand that this is a matter of personal preference, so please take a look at LightService as well!
