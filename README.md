# SourcedConfig

## Consider using `anyway_config` instead

Consider using [https://github.com/palkan/anyway_config](https://github.com/palkan/anyway_config) as it is better and 
overlaps with most of the functionality here. 

### Replicating the functionality of `sourced_config` with `anyway_config`

To load a config file from S3, you can use the `anyway_config` gem with
a custom loader, e.g. something like:

```ruby
class S3FileLoader < Anyway::Loaders::Base
  def call(
    name:, # config name
    config_path:, # path to YML config
    **options # custom options can be passed via Anyway::Config.loader_options example: "custom", option: "blah"
  ) 
    trace!(:s3_file) do
      s3 = Aws::S3::Client.new(retry_limit: 10, region: options[:region])
      resp = s3.get_object(bucket: options[:bucket], key: config_path)
      yaml = YAML.safe_load(resp.body)
      yaml[name.to_s]
    rescue Aws::S3::Errors::ServiceError
      # raise error or just return {}
    end
  end
end

Anyway.loaders.insert_before :env, :s3_file, S3FileLoader
```

### Loading i18n from sources other than YML

You could use an appropiate client and create I18n backend. E.g. Google Sheets could be 
loaded using `GSheetsClient` in this gem.

You can then create an `I18n` backend:

```ruby
class I18nBackend < ::I18n::Backend::Simple
   def load_translations
      client = GSheetsClient.new(SHEET_URL)
      I18n.available_locales.each do |locale|
        Rails.logger.info "Load I18n: for supported locale #{locale}"
        store_translations(locale, client.load(locale.to_sym)[locale])
     end
   end 
end
```

## `sourced_config` Description

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
