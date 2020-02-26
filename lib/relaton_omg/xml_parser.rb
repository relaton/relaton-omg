require "nokogiri"

module RelatonOmg
  class XMLParser < RelatonBib::XMLParser
    class << self
      def from_xml(xml)
        doc = Nokogiri::XML(xml)
        doc.remove_namespaces!
        item = doc.at("/bibitem|/bibdata")
        if item
          RelatonOmg::OmgBibliographicItem.new(item_data(item))
        else
          warn "[relato-omg] can't find bibitem or bibdata element in the XML"
        end
      end

      private

      def item_data(ietfitem)
        data = super
        # ext = ietfitem.at "./ext"
        # return data unless ext

        # data[:doctype] = ext.at("./doctype")&.text
        data
      end
    end
  end
end
