require "nokogiri"
require "relaton_bib"
require "relaton_omg/version"
require "relaton_omg/scrapper"
require "relaton_omg/omg_bibliography"
require "relaton_omg/omg_bibliographic_item"

module RelatonOmg
  # Returns hash of XML reammar
  # @return [String]
  def self.grammar_hash
    gem_path = File.expand_path "..", __dir__
    grammars_path = File.join gem_path, "grammars", "*"
    grammars = Dir[grammars_path].sort.map { |gp| File.read gp }.join
    Digest::MD5.hexdigest grammars
  end
end