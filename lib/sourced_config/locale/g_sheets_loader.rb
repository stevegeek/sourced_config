# frozen_string_literal: true

require "csv"

module SourcedConfig
  module Locale
    class GSheetsLoader
      class << self
        def call(locale, url, options = {})
          Rails.logger.debug { "[locale - #{locale}] Strings read (as UTF-8) from remote URL" }
          content = get_content(url)
          text = content.body.force_encoding("UTF-8")
          CSV.parse(text, **{col_sep: "\t", quote_char: "^", headers: true}.merge(options))
        end

        private

        def get_content(url)
          uri = URI.parse(url)
          http = Net::HTTP.new(uri.host, uri.port)
          http.read_timeout = 5
          http.open_timeout = 5
          http.use_ssl = true
          http.start do |http|
            http.get(uri.request_uri)
          end
        end
      end
    end
  end
end
