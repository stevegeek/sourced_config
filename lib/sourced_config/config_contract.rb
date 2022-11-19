# frozen_string_literal: true

require "dry-monads"
require "dry-validation"

module SourcedConfig
  class ConfigContract < ::Dry::Validation::Contract
    ::Dry::Validation.load_extensions(:monads)

    class LocalesConfig < ConfigContract
      params do
        required(:supported).filled(array[:string])
        optional(:load_from_type).filled(:string)
        optional(:load_from_source).maybe(:string)
      end
    end

    params do
      required(:locales).hash(LocalesConfig.schema)
    end

    class << self
      def key_names
        schema.key_map.map(&:name)
      end
    end
  end
end
