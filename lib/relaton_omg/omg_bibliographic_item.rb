module RelatonOmg
  class OmgBibliographicItem < RelatonBib::BibliographicItem
    # @return [String, NilClass]
    attr_reader :doctype

    # @param doctype [String]
    # @param keyword [Array<String>]
    def initialize(**args)
      @doctype = args.delete :doctype
      # @keyword = args.delete(:keyword) || []
      super
    end

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
      super builder, **opts do |b|
        # if opts[:bibdata]
        #   b.ext do
        #     b.doctype doctype if doctype
        #   end
        # end
      end
    end

    # @return [Hash]
    def to_hash
      hash = super
      hash["doctype"] = doctype if doctype
      hash
    end
  end
end
