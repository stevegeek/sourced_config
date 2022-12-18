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
        template "templates/config.yml.erb", "config/config.yml.erb"
        template "templates/app_config_schema.rb", "app/config/app_config_schema.rb"
      end
    end
  end
end
