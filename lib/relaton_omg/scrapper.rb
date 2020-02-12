require "nokogiri"

module RelatonOmg
  module Scrapper
    URL_PATTERN = "https://www.omg.org/spec/"

    class << self
      def scrape_page(ref)
        %r{OMG (?<acronym>[^\s]+)\s?(?<version>.*)} =~ ref
        return unless acronym

        url = URL_PATTERN + acronym
        url += "/" + version if version
        doc = Nokogiri::HTML open(URI(url))
        OmgBibliographicItem.new item(doc, acronym)
      end

      private

      def item(doc, acronym)
        {
          id: fetch_id(doc, acronym),
          fetched: Date.today.to_s,
          title: fetch_title(doc),
          abstract: fetch_abstract(doc),
          version: fetch_version(doc),
          date: fetch_date(doc),
          docstatus: fetch_status(doc),
          link: fetch_link(doc),
          relation: fetch_relation(doc)
        }
      end

      def fetch_id(doc, acronym)
        acronym + version(doc)
      end

      def fetch_title(doc)
        content = doc.at('//dt[.="Title:"]/following-sibling::dd').text
        title = RelatonBib::FormattedString.new content: content, language: "en", script: "Latn"
        [RelatonBib::TypedTitleString.new(type: "main", title: title)]
      end

      def fetch_abstract(doc)
        content = doc.at('//section[@id="document-metadata"]/p').text
        [{ content: content, language: "en", script: "Latn" }]
      end

      def fetch_version(doc)
        RelatonBib::BibliographicItem::Version.new pub_date(doc), [version(doc)]
      end

      def version(doc)
        doc.at('//dt[.="Version:"]/following-sibling::dd/p/text()').text.strip
      end

      def fetch_date(doc)
        [type: "published", on: pub_date(doc).to_s]
      end

      def pub_date(doc)
        Date.parse doc.at('//dt[.="Publication Date:"]/following-sibling::dd').text.strip
      end

      def fetch_status(doc)
        status = doc.at('//dt[.="Document Status:"]/following-sibling::dd')
        stage = status.text.strip.match(/\w+/).to_s
        RelatonBib::DocumentStatus.new(stage: stage)
      end

      def fetch_link(doc)
        links = []
        a = doc.at('//dt[.="This Document:"]/following-sibling::dd/a')
        links << { type: "src", content: a[:href] } if a
        pdf = doc.at('//a[@class="download-document"]')
        links << { type: "pdf", content: pdf[:href] } if pdf
        links
      end

      def fetch_relation(doc)
        []
      end
    end
  end
end