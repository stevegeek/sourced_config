# frozen_string_literal: true

require "rails/generators/base"

module SourcedConfig
  module Generators
    # The Install generator `sourced_config:install`
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path(__dir__)

      desc "Creates an initializer for the gem."
      def copy_tasks
        template "templates/sourced_config.rb", "config/initializers/sourced_config.rb"

        append_to_file 'config/application.rb' do
<<RUBY
    # Initialise watch of application configuration
    config.after_initialize { |app| ::SourcedConfig.setup(app) }
    config.before_eager_load { |app| ::SourcedConfig.setup(app) }
RUBY
        end
      end
    end
  end
end