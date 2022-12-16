# frozen-string-literal: true

class AppConfigSchema < SourcedConfig::ConfigContract
  class LocalesConfig < SourcedConfig::ConfigContract
    params do
      required(:supported).filled(array[:string])
      optional(:load_from_type).filled(:string)
      optional(:load_from_source).maybe(:string)
    end
  end

  schema do
    required(:locales).hash(LocalesConfig.schema)

    # TODO: Add your own config keys here...
    # ...
  end
end
