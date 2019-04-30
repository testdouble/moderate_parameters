![Moderate Parameters](https://user-images.githubusercontent.com/4054771/56984869-ecb46a80-6b3b-11e9-98b3-c5d5ab57c499.png)

By [Hint.io](https://hint.io)

In our experience with [UpgradeRails](https://www.upgraderails.com), the migration from [protected_attributes](https://github.com/rails/protected_attributes) to [strong_parameters](https://api.rubyonrails.org/classes/ActionController/StrongParameters.html) can leave more questions than answers. It can be difficult to determine what data is originating from within the app and what is coming from the internet. Moderate Parameters is a tool that provides safety nets and logging of data sources in the controller by extending `ActionController::Parameters` functionality.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'moderate_parameters'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install moderate_parameters

## Usage

Given a form at `/people/new` that submits data to the `PeopleController#create` action like so:

```ruby
{ person: { name: 'Kyle', age: '26', height: '180' } }
```

With a model that looks like:

```ruby
class Person < ActiveRecord::Base
  attr_accessible :name, :age, :height

  . . .

end
```

And a controller looks like this:

```ruby
class PeopleController < ActionController::Base
  def create
    Person.create(params[:person])
  end

  . . .

end
```

We can add `moderate_parameters` by following the `strong_parameters` implementation method with a couple slight changes.

Add a private params method for the controller calling `moderate` (with `controller_name` and `action_name` as the first two args) instead of `permit`:

```ruby
class PeopleController < ActionController::Base
  def create
    Person.create(person_params) # Was Person.create(params[:person])
  end

  . . .

  private

    def person_params
      params.require(:person).moderate(controller_name, action_name, :name)
    end
end
```

This will cause the `person_params` to flow the same way they did before (getting passed to the model without interruption),
but the params that are not included in the argument of `moderate` will be logged to `/log/moderate_params.log`

Meaning that, after submitting the aforementioned data, our `moderate_parameters.log` will look like so:

    people#create Top Level is missing: age
    people#create Top Level is missing: height

We can fix this by adding `age` and `height` to `person_params` like so:

```ruby
class PeopleController < ActionController::Base
  def create
    Person.create(person_params)
  end

  . . .

  private

    def person_params
      params.require(:person).moderate(controller_name, action_name, :name, :age, :height)
    end
end
```

We can then hit submit data from the form at `/people/new` and see that no new lines are added to the `moderate_parameters.log` file.

This means that we can remove `moderate_parameters` and move to using `permit` as a part of `strong_parameters`:

```ruby
class PeopleController < ActionController::Base
  def create
    Person.create(person_params)
  end

  . . .

  private

    def person_params
      params.require(:person).permit(:name, :age, :height)
    end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hintmedia/moderate_parameters. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the moderate_parameters project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/hintmedia/moderate_parameters/blob/master/CODE_OF_CONDUCT.md).
