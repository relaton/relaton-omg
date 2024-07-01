# frozen_string_literal:true

module RelatonOmg
  # OMG bibliography module
  module OmgBibliography
    class << self
      # @param code [String] the OMG standard reference
      # @return [RelatonOmg::OmgBibliographicItem]
      def search(text)
        Scraper.scrape_page text
      end

      # @param code [String] the OMG standard reference
      # @param year [String] the year the standard was published (optional)
      # @param opts [Hash] options
      # @return [RelatonOmg::OmgBibliographicItem]
      def get(code, _year = nil, _opts = {})
        Util.info "Fetching from www.omg.org ...", key: code
        result = search code
        if result
          Util.info "Found: `#{result.docidentifier.first.id}`", key: code
        else
          Util.info "Not found.", key: code
        end
        result
      end
    end
  end
end
