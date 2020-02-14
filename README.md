<p align="center">
  <img src="https://user-images.githubusercontent.com/4054771/56985278-db1f9280-6b3c-11e9-8719-f48e2ab4885d.png" alt="Moderate Parameters" background>
</p>


By [Hint.io](https://hint.io)

[![Gem Version](https://badge.fury.io/rb/moderate_parameters.svg)](https://badge.fury.io/rb/moderate_parameters) ![CI](https://github.com/hintmedia/moderate_parameters/workflows/CI/badge.svg) [![Maintainability](https://api.codeclimate.com/v1/badges/4971eb01d5bd98dbac8b/maintainability)](https://codeclimate.com/github/hintmedia/moderate_parameters/maintainability)

In our experience with [UpgradeRails](https://www.upgraderails.com), the migration from [protected_attributes](https://github.com/rails/protected_attributes) to [strong_parameters](https://api.rubyonrails.org/classes/ActionController/StrongParameters.html) can leave more questions than answers. It can be difficult to determine what data is originating from within the app and what is coming from the internet.

Moderate Parameters is a set of tools providing logging of data sources in the controller by extending `ActionController::Parameters` functionality.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'moderate_parameters'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install moderate_parameters

Then add the initializer by running:

    $ bundle exec rails g moderate_parameters:install

This will add an initializer to your rails app for turning on/off functionality.

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

This means that we can remove `moderate_parameters` and move to using `permit` as the final migration step of `strong_parameters`:

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

It is only _**AFTER**_ this final step of the `strong_parameters` migration has been completed that you can safely remove the `protected_attributes` line in the model:

```ruby
class Person < ActiveRecord::Base
  # attr_accessible :name, :age, :height

  . . .

end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hintmedia/moderate_parameters. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the moderate_parameters project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/hintmedia/moderate_parameters/blob/master/CODE_OF_CONDUCT.md).
