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

## Usage

TODO: Write usage instructions here

- Add an initializer to your app to configure the gem
- Add a base config file to your app

Access config with `SourcedConfig[key]`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/sourced_config.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
