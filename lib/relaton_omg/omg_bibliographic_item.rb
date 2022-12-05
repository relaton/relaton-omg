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
        bib_hash = RelatonOmg::HashConverter.hash_to_bib(hash)
        new(**bib_hash)
      end

      # @param file [String] path to XML file
      # @return [RelatonOmg::OmgBibliographicItem]
      def from_xml(file)
        XMLParser.from_xml File.read file, encoding: "UTF-8"
      end
    end

    #
    # Fetches flavor shcema version from XML
    #
    # @return [String] flavor shcema version
    #
    def ext_schema
      @ext_schema ||= schema_versions["relaton-model-omg"]
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
