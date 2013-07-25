# Interactor

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

```ruby
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
  include Interactor

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

### 🚧  Under Contruction

## Conventions

We love Rails, and we use Interactor with Rails. We put our interactors in `app/interactors` and we name them as verbs:

* `AddProductToCart`
* `AuthenticateUser`
* `PlaceOrder`
* `RegisterUser`
* `RemoveProductFromCart`

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
