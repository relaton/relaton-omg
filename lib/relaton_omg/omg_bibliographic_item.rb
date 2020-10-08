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

    # @param opts [Hash]
    # @option opts [Nokogiri::XML::Builder] :builder XML builder
    # @option opts [Boolean] :bibdata
    # @option opts [String] :lang language
    # @return [String] XML
    def to_xml(**opts)
      opts[:date_format] ||= :short
      super
    end
  end
end
