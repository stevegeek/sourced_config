# SourcedConfig

App configuration & Locales for Rails apps where the config is loaded from a remote or local non-repo source.

Useful in apps that are 'white-labeled' and can have different configurations for different deployments.

Config can be loaded from:
- S3
- Local files

Locale data can be loaded from:
- S3
- Local files
- Google Spreadsheets

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add sourced_config

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install sourced_config

Then install the initializer by executing:

    $ rails g sourced_config:install


## Usage


### Setup:

1. Add an initializer to your app to configure the gem (eg with the generator `rails g sourced_config:install`)
    - To manually install create an initializer, and add the following to your `Application` class:
      ```ruby
           # Initialise watch of application configuration
           config.after_initialize { |app| ::SourcedConfig.setup(app) }
           config.before_eager_load { |app| ::SourcedConfig.setup(app) }
      ```  
2. Add a schema class to your app to define the config schema (eg `app/config/app_contract.rb` which inherits from `SourcedConfig::ConfigContract`)
3. Configure your app for the `aws-sdk-s3` gem
    - If you are using the `aws-sdk-s3` gem in your app, you can skip this step
    - otherwise read `https://github.com/aws/aws-sdk-ruby#configuration`
4. Add a base config file to your app (eg `config/config.yml.erb` as per your initializer)

### Example schema:

```ruby
class AppContract < SourcedConfig::ConfigContract
  class ColorContract < SourcedConfig::ConfigContract 
    params do
      optional(:header).maybe(:string)
      optional(:footer).maybe(:string)
    end
  end
  
  params do
    required(:environment).filled(:string)
    required(:app_name).filled(:string)
    optional(:colors).hash(ColorContract.schema)
  end
end
```

### Accessing configuration:

Access config values in your code with `SourcedConfig[key]`

```ruby
SourcedConfig[:environment]
SourcedConfig[:colors][:footer]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/sourced_config.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
