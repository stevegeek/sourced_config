# frozen_string_literal: true

require "csv"

module SourcedConfig
  module Locale
    class GSheetsClient
      def initialize(url)
        @url = url
      end

      attr_reader :url

      def load(locale)
        Rails.logger.debug { "[locale - #{locale}] Strings read (as UTF-8) from remote URL #{url}" }
        content = get_content
        parse_body(content.body.force_encoding("UTF-8")).reduce({}) do |memo, row|
          parse_item(row, memo)
        end
      rescue => e
        Rails.logger.error "[locale - #{locale}] Could not fetch TSV doc directly from Google Spreadsheets: #{e.message}"
        {}
      end

      private

      def parse_body(text)
        CSV.parse(text, col_sep: "\t", quote_char: "^", skip_lines: /^\s*#.*$/, skip_blanks: true, headers: true)
      end

      def parse_item(item, locale_hash)
        *keys, string = item.to_a.map { |x| x[1] }
        keys.compact!
        leaf_item = keys[..-2].reduce(locale_hash) do |h, k|
          next h unless k.present?
          h[k] ||= {}
        end
        leaf_item[keys.last] = string
        locale_hash
      end

      def get_content
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
