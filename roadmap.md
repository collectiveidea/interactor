# Interactor 3 Roadmap

The API for Interactor 2 has limitations and some potential causes of confusion.
Interactor 3 aims to address these issues and further refine the public API.

## Interactor API

### The Problem

Interactor's primary public API method is the `perform` class method. Why
`perform`? Good question. The answer is because we had to pick *something*.

* `perform`
* `run`
* `call`
* `execute`
* `work`

The suggestion has been made to alias all of these methods and leave it to
personal preference. There are two problems with that suggestion:

1. Interactor's purpose is to provide convention around a simple pattern. To
   dilute the API with multiple approaches to its most basic function would
   weaken the convention.
2. While aliases may work on the class level from which the interactor is
   called, the developer still must define an instance method to describe the
   interactor's actual behavior. Aliasing an arbitrary number of methods in a
   way that can determine which method the developer actually defined
   (overwrote) muddies the waters and adds a great deal of complexity.

### Proposed Solution

On both the class level and the instance level, interactors will use the `call`
method rather than `perform`, because… Ruby. The `call` method is a common Ruby
convention for method objects. It also has nice symmetry with Ruby's procs and
lambdas.

Fun argument [here](https://github.com/collectiveidea/interactor/issues/27).

```ruby
class SessionsController < ApplicationController
  def create
    AuthenticateUser.call(email: params[:email], password: params[:password])
  end
end

class AuthenticateUser
  include Interactor

  def call
    # TODO
  end
end
```

## Context API

### The Problem

So far contexts have been treated as hashes… most of the time.

```ruby
context[:hello] = "world"
context[:hello] # => "world"
context[:foo] # => nil
```

There's nothing particularly troubling about this interface. However, there's
often confusion because `Interactor.perform` accepts a hash and the developer
might expect the resulting `context` to behave in the same way, or even be the
same object. To reinforce this belief, the context object became a simple
delegator to the underlying hash, which avoided headaches resulting from hashes
with indifferent access or with strong parameter processing.

### Proposed Solution

The context built during performance of an interactor should no longer act as a
hash. Context instances should be basic objects responding to setter and getter
methods. For instance:

```ruby
context.hello = "world"
context.hello # => "world"
context.foo # => nil
context.foo = "bar"
context.foo # => "bar"
```

This feels much cleaner. It also shrinks the `Interactor::Context` API by
approximately `Hash.methods.count`.

## Magical Context Access

### The Problem

Another confusing bit is that most often, context values are accessed from
within an instance of an interactor and the interactor allows direct method
access to context values. The original intent here is to make values easily
accessible from the controller. The unfortunate side effect is the temptation to
use direct access from within the interactor itself for convenience.

```ruby
class SessionsController < ApplicationController
  def create
    AuthenticateUser.perform(email: params[:email], password: params[:password])
  end
end

class AuthenticateUser
  include Interactor

  def perform
    user = User.find_by(email: email) # <- Magical access to context[:email]

    if user && user.authenticate(password) # <- Magical access to context[:password]
      context[:user] = user
    else
      fail!
    end
  end
end
```

For a newcomer to Interactor, it's not at all apparent where the `email` or
`password` methods originate.

### Proposed Solution

From within an interactor there will be no magical access to the underlying
context. Accessing the context will be explicit.

```ruby
class AuthenticateUser
  include Interactor

  def call
    user = User.find_by(email: context.email) # <- No magic!

    if user && user.authenticate(context.password) # <- No magic!
      context.user = user
    else
      fail!
    end
  end
end
```

## Interactor Setup

### The Problem

The `setup` method inside of an interactor is intended to massage the incoming
context in preparation for performance.

```ruby
class AddCommentToPost
  include Interactor

  def setup
    context[:post] ||= Post.find(post_id)
  end

  def perform
    # TODO: Create comment belonging to context[:post]
  end
end
```

The `setup` method above allows the interactor to be performed by providing
either a `post_id` or an entire `post`.

The problem is that it's not easy to run multiple setup methods. If the
interactor above were to include some other concern that defines its own
`setup` method, one would clobber the other.

It's also not currently possible to define a `teardown` (or similar) method to
run after an interactor's performance. This could be useful in timing execution
or performing other maintenance operations.

### Proposed Solution

The `setup` instance will be replaced by a class-level `before` method.

```ruby
class AddCommentToPost
  include Interactor

  before do
    context.post ||= Post.find(context.post_id)
  end

  def call
    # TODO: Create comment belonging to context.post
  end
end
```

A similar `after` method will exist. An `around` method can also be called and
is expected to yield to the interactor's performance (including before and
after filters).

```ruby
class InteractorTimer
  extend ActiveSupport::Concern

  included do
    around do
      execution_time = Benchmark.realtime { yield }
      # TODO: Do something with the execution time
    end
  end
end

class AddCommentToPost
  include Interactor
  include InteractorTimer

  before do
    context.post ||= Post.find(context.post_id)
  end

  def call
    # TODO
  end
end
```

## Return Value

### The Problem

The `Interactor.perform` method used from the controller has always returned an
instance of the interactor class. The original intent of this decision was to
make any methods available on the instance of your interactor available to the
controller.

The problem is that removing magical access to context values from the
interactor instance has the effect of making the controller a little more
unruly.

```ruby
class SessionsController < ApplicationController
  def create
    interactor = AuthenticateUser.perform(email: params[:email], password: params[:password])

    if interactor.context.success?
      redirect_to interactor.context.user
    else
      render :new
    end
  end
end
```

### Proposed Solution

The `Interactor.perform` method will return the mutated context resulting from
performance of the interactor instance. The instance itself is a throwaway. If
the interactor wishes to make data available outside of its own performance,
that data should be added to the context.

```ruby
class SessionsController < ApplicationController
  def create
    result = AuthenticateUser.call(email: params[:email], password: params[:password])

    if result.success?
      redirect_to result.user
    else
      render :new
    end
  end
end
```
