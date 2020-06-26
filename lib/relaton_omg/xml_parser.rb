require "nokogiri"

module RelatonOmg
  class XMLParser < RelatonBib::XMLParser
    class << self
      private

      # def item_data(ietfitem)
      #   data = super
      #   ext = ietfitem.at "./ext"
      #   return data unless ext

      #   data[:doctype] = ext.at("./doctype")&.text
      #   data
      # end

      # @param item_hash [Hash]
      # @return [RelatonOmg::OmgBibliographicItem]
      def bib_item(item_hash)
        OmgBibliographicItem.new item_hash
      end
    end
  end
end
