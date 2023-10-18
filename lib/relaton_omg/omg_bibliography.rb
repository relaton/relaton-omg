# frozen_string_literal:true

module RelatonOmg
  # OMG bibliography module
  module OmgBibliography
    class << self
      # @param code [String] the OMG standard reference
      # @return [RelatonOmg::OmgBibliographicItem]
      def search(text)
        Scrapper.scrape_page text
      end

      # @param code [String] the OMG standard reference
      # @param year [String] the year the standard was published (optional)
      # @param opts [Hash] options
      # @return [RelatonOmg::OmgBibliographicItem]
      def get(code, _year = nil, _opts = {})
        Util.warn "(#{code}) Fetching from www.omg.org ..."
        result = search code
        if result
          Util.warn "(#{code}) Found: `#{result.docidentifier.first.id}`"
        else
          Util.warn "(#{code}) Not found."
        end
        result
      end
    end
  end
end
