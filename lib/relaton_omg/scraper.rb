require "nokogiri"

module RelatonOmg
  class Scraper
    URL_PATTERN = "https://www.omg.org/spec/".freeze

    def initialize(acronym, version = nil, spec = nil)
      @acronym = acronym
      @version = version
      @spec = spec
    end

    def self.scrape_page(ref)
      %r{^OMG (?<acronym>[^\s]+)(?:[\s/](?<version>[\d.]+(?:\sbeta(?:\s\d)?)?))?(?:[\s/](?<spec>\w+))?$} =~ ref
      return unless acronym

      scraper = new(acronym, version, spec)
      doc = scraper.get_doc
      return if doc.nil? || scraper.fetch_link.empty?

      OmgBibliographicItem.new(**scraper.item)
    end

    def get_doc
      @url = "#{URL_PATTERN}#{@acronym}/"
      @url += @version.gsub(' ', '/') if @version
      @doc = Nokogiri::HTML OpenURI.open_uri(@url, open_timeout: 10)
    rescue OpenURI::HTTPError, URI::InvalidURIError, Net::OpenTimeout => e
      return if e.is_a?(URI::InvalidURIError) || e.io.status[0] == "404"

      raise RelatonBib::RequestError, "Unable acces #{@url} (#{e.io.status.join(' ')})"
    end

    def item
      {
        id: fetch_id,
        fetched: Date.today.to_s,
        docid: fetch_docid,
        title: fetch_title,
        abstract: fetch_abstract,
        version: fetch_version,
        date: fetch_date,
        docstatus: fetch_status,
        link: fetch_link,
        relation: fetch_relation,
        keyword: fetch_keyword,
        license: fetch_license,
      }
    end

    def fetch_id
      "#{@acronym}#{doc_version}#{@spec}"
    end

    def fetch_title
      content = @doc.at('//dt[.="Title:"]/following-sibling::dd').text
      content += ": #{@spec}" if @spec
      title = RelatonBib::FormattedString.new content: content, language: "en", script: "Latn"
      [RelatonBib::TypedTitleString.new(type: "main", title: title)]
    end

    def fetch_docid
      id = ["OMG", @acronym]
      id << doc_version if doc_version
      id << @spec if @spec
      [RelatonBib::DocumentIdentifier.new(id: id.join(" "), type: "OMG", primary: true)]
    end

    def fetch_abstract
      content = @doc.at('//section[@id="document-metadata"]/div/div/p').text
      [{ content: content, language: "en", script: "Latn" }]
    end

    def fetch_version
      [RelatonBib::BibliographicItem::Version.new(pub_date, doc_version)]
    end

    def doc_version
      @doc_version ||= @doc.at('//dt[.="Version:"]/following-sibling::dd/p/span').text
    end

    def fetch_date
      [type: "published", on: pub_date.to_s]
    end

    def pub_date
      Date.parse @doc.at('//dt[.="Publication Date:"]/following-sibling::dd').text.strip
    end

    def fetch_status
      status = @doc.at('//dt[.="Document Status:"]/following-sibling::dd')
      stage = status.text.strip.match(/\w+/).to_s
      RelatonBib::DocumentStatus.new(stage: stage)
    end

    def fetch_link
      return @link if @link

      @links = []
      if @spec
        a = @doc.at("//a[@href='#{@url}/#{@spec}/PDF']")
        @links << { type: "src", content: a[:href] } if a
      else
        a = @doc.at('//dt[.="This Document:"]/following-sibling::dd/a')
        @links << { type: "src", content: a[:href] } if a
        pdf = @doc.at('//a[@class="download-document"]')
        @links << { type: "pdf", content: pdf[:href] } if pdf
      end
      @links
    end

    def fetch_relation
      v = @doc.xpath('//h2[.="History"]/following-sibling::section/div/table/tbody/tr')
      v.reduce([]) do |mem, row|
        ver = row.at("td").text
        unless ver == doc_version
          acronym = row.at("td[3]/a")[:href].split("/")[4]
          fref = RelatonBib::FormattedRef.new content: "OMG #{acronym} #{ver}"
          bibitem = OmgBibliographicItem.new formattedref: fref
          mem << { type: "obsoletes", bibitem: bibitem }
        end
        mem
      end
    end

    def fetch_keyword
      @doc.xpath('//dt[.="Categories:"]/following-sibling::dd/ul/li/a/em').map &:text
    end

    def fetch_license
      @doc.xpath(
        '//dt/span/a[contains(., "IPR Mode")]/../../following-sibling::dd/span',
      ).map { |l| l.text.match(/[\w\s-]+/).to_s.strip }
    end
  end
end
