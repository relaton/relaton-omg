require "nokogiri"
require "relaton/bib"
require_relative "omg/version"
require_relative "omg/util"
# require "relaton_omg/scraper"
# require "relaton_omg/omg_bibliography"
require_relative "omg/item"
require_relative "omg/bibitem"
require_relative "omg/bibdata"
# require "relaton_omg/xml_parser"
# require "relaton_omg/hash_converter"

module Relaton
  module Omg
    # Returns hash of XML reammar
    # @return [String]
    def self.grammar_hash
      # gem_path = File.expand_path "..", __dir__
      # grammars_path = File.join gem_path, "grammars", "*"
      # grammars = Dir[grammars_path].sort.map { |gp| File.read gp }.join
      Digest::MD5.hexdigest Relaton::Omg::VERSION + Relaton::Bib::VERSION # grammars
    end
  end
end
