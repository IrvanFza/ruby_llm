# frozen_string_literal: true

module RubyLLM
  # Tool results the model can cite. Serializes to the search-results
  # convention: a tool message whose content is {"search_results": [...]}
  # renders as citable blocks on providers with citation support.
  #
  #   def execute(query:)
  #     RubyLLM::SearchResults.new(
  #       title: 'Q4 Report',
  #       url: 'https://drive.example.com/q4-report',
  #       text: report_text
  #     )
  #   end
  class SearchResults
    KEY = 'search_results'

    attr_reader :results

    def initialize(*results, **result)
      results << result if result.any?
      @results = results.map { |entry| normalize(entry) }
      raise ArgumentError, 'SearchResults requires at least one result' if @results.empty?
    end

    def self.from_content(content)
      return unless content.is_a?(String) && content.lstrip.start_with?('{')

      parsed = JSON.parse(content)
      entries = parsed[KEY]
      return unless entries.is_a?(Array) && entries.any?

      new(*entries)
    rescue JSON::ParserError, ArgumentError
      nil
    end

    def to_h
      { KEY => results }
    end

    def to_json(*args)
      JSON.generate(to_h, *args)
    end

    private

    def normalize(entry)
      entry = Utils.deep_symbolize_keys(entry.to_h)
      raise ArgumentError, 'Search results require :title and :text' unless entry[:title] && entry[:text]

      entry.slice(:title, :url, :text)
    end
  end
end
