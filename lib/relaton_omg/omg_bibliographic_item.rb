module RelatonOmg
  class OmgBibliographicItem < RelatonBib::BibliographicItem
    # @return [String, NilClass]
    class << self
      # @param file [String] path to YAML file
      # @return [RelatonOmg::OmgBibliographicItem]
      def from_yaml(file)
        from_hash YAML.load_file(file)
      end

      # @param hash [Hash]
      # @return [RelatonOmg::OmgBibliographicItem]
      def from_hash(hash)
        new RelatonOmg::HashConverter.hash_to_bib(hash)
      end

      # @param file [String] path to XML file
      # @return [RelatonOmg::OmgBibliographicItem]
      def from_xml(file)
        XMLParser.from_xml File.read file, encoding: "UTF-8"
      end
    end

    # @param builder
    # @param opts [Hash]
    # @option opts [Symbol, NilClass] :date_format (:short), :full
    def to_xml(builder = nil, **opts)
      opts[:date_format] ||= :short
      super
    end
  end
end
