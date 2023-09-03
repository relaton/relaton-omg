require "relaton/processor"
require "relaton_omg/xml_parser"

module RelatonOmg
  class Processor < Relaton::Processor
    def initialize
      @short = :relaton_omg
      @prefix = "OMG"
      @defaultprefix = /^OMG /
      @idtype = "OMG"
    end

    # @param code [String]
    # @param date [String, NilClass] year
    # @param opts [Hash]
    # @return [RelatonOmg::OmgBibliographicItem]
    def get(code, date, opts)
      ::RelatonOmg::OmgBibliography.get(code, date, opts)
    end

    # @param xml [String]
    # @return [RelatonOmg::OmgBibliographicItem]
    def from_xml(xml)
      ::RelatonOmg::XMLParser.from_xml xml
    end

    # @param hash [Hash]
    # @return [RelatonOmg::OmgBibliographicItem]
    def hash_to_bib(hash)
      # item_hash = ::RelatonOmg::HashConverter.hash_to_bib(hash)
      ::RelatonOmg::OmgBibliographicItem.from_hash hash
    end

    # Returns hash of XML grammar
    # @return [String]
    def grammar_hash
      @grammar_hash ||= ::RelatonOmg.grammar_hash
    end
  end
end
