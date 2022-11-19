# frozen_string_literal: true

require_relative "lib/sourced_config/version"

Gem::Specification.new do |spec|
  spec.name = "sourced_config"
  spec.version = SourcedConfig::VERSION
  spec.authors = ["Stephen Ierodiaconou"]
  spec.email = ["stevegeek@gmail.com"]

  spec.summary = "Load configuration & locales for Rails apps from a remote or local non-repo source."
  spec.description = "Load configuration & locales for Rails apps from a remote or local non-repo source."
  spec.homepage = "https://github.com/stevegeek/sourced_config"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "aws-sdk-s3"
  spec.add_dependency "rails", ">= 6"
  spec.add_dependency "dry-monads"
  spec.add_dependency "dry-validation"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
