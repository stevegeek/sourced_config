# frozen_string_literal: true

require "dry-monads"
require "dry-validation"

module SourcedConfig
  class ConfigContract < ::Dry::Validation::Contract
    ::Dry::Validation.load_extensions(:monads)

    class << self
      def key_names
        schema.key_map.map(&:name)
      end
    end
  end
end
