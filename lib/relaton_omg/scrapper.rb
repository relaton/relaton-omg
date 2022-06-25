require "nokogiri"

module RelatonOmg
  module Scrapper
    URL_PATTERN = "https://www.omg.org/spec/".freeze

    class << self
      def scrape_page(ref) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        %r{OMG (?<acronym>[^\s]+)\s?(?<version>.*)} =~ ref
        return unless acronym

        url = URL_PATTERN + acronym
        url += "/#{version}" if version
        doc = Nokogiri::HTML OpenURI.open_uri(url, open_timeout: 10)
        OmgBibliographicItem.new(**item(doc, acronym))
      rescue OpenURI::HTTPError, URI::InvalidURIError, Net::OpenTimeout => e
        if e.is_a?(URI::InvalidURIError) || e.io.status[0] == "404"
          warn %{[relaton-omg] no document found for "#{ref}" reference.}
          return
        end

        raise RelatonBib::RequestError, "Unable acces #{url} (#{e.io.status.join(" ")}"
      end

      private

      def item(doc, acronym) # rubocop:disable Metrics/MethodLength
        {
          id: fetch_id(doc, acronym),
          fetched: Date.today.to_s,
          docid: fetch_docid(doc, acronym),
          title: fetch_title(doc),
          abstract: fetch_abstract(doc),
          version: fetch_version(doc),
          date: fetch_date(doc),
          docstatus: fetch_status(doc),
          link: fetch_link(doc),
          relation: fetch_relation(doc),
          keyword: fetch_keyword(doc),
          license: fetch_license(doc),
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

      def fetch_docid(doc, acronym)
        id = [acronym]
        if (ver = version(doc))
          id << ver
        end
        [RelatonBib::DocumentIdentifier.new(id: id.join(" "), type: "OMG", primary: true)]
      end

      def fetch_abstract(doc)
        content = doc.at('//section[@id="document-metadata"]/div/div/p').text
        [{ content: content, language: "en", script: "Latn" }]
      end

      def fetch_version(doc)
        [RelatonBib::BibliographicItem::Version.new(pub_date(doc), version(doc))]
      end

      def version(doc)
        doc.at('//dt[.="Version:"]/following-sibling::dd/p/span').text
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

      def fetch_relation(doc) # rubocop:disable Metrics/MethodLength
        current_version = version(doc)
        v = doc.xpath('//h2[.="History"]/following-sibling::section/div/table/tbody/tr')
        v.reduce([]) do |mem, row|
          ver = row.at("td").text
          unless ver == current_version
            acronym = row.at("td[3]/a")[:href].split("/")[4]
            fref = RelatonBib::FormattedRef.new content: "OMG #{acronym} #{ver}"
            bibitem = OmgBibliographicItem.new formattedref: fref
            mem << { type: "obsoletes", bibitem: bibitem }
          end
          mem
        end
      end

      def fetch_keyword(doc)
        doc.xpath('//dt[.="Categories:"]/following-sibling::dd/ul/li/a/em').map &:text
      end

      def fetch_license(doc)
        doc.xpath(
          '//dt/span/a[contains(., "IPR Mode")]/../../following-sibling::dd/span',
        ).map { |l| l.text.match(/[\w\s-]+/).to_s.strip }
      end
    end
  end
end