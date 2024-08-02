require "jing"

RSpec.describe RelatonOmg do
  it "has a version number" do
    expect(RelatonOmg::VERSION).not_to be nil
  end

  it "returs grammar hash" do
    hash = RelatonOmg.grammar_hash
    expect(hash).to be_instance_of String
    expect(hash.size).to eq 32
  end

  context "fetch OMG documents" do
    it "get specific version", vcr: "omg_ami4ccm_1_0" do
      expect do
        item = RelatonOmg::OmgBibliography.get "OMG AMI4CCM 1.0"
        expect(item).to be_instance_of RelatonOmg::OmgBibliographicItem
        file = "spec/fixtures/omg_ami4ccm_1_0.xml"
        xml = item.to_xml # bibdata: true
        File.write file, xml, encoding: "utf-8" unless File.exist? file
        expect(xml).to be_equivalent_to File.read(file, encoding: "utf-8").sub(
          %r{(?<=<fetched>)\d{4}-\d{2}-\d{2}}, Date.today.to_s
        )
        schema = Jing.new "grammars/relaton-omg-compile.rng"
        errors = schema.validate file
        expect(errors).to eq []
      end.to output(
        include("[relaton-omg] INFO: (OMG AMI4CCM 1.0) Fetching from www.omg.org ...",
                "[relaton-omg] INFO: (OMG AMI4CCM 1.0) Found: `OMG AMI4CCM 1.0`"),
      ).to_stderr_from_any_process
    end

    it "get last version" do
      VCR.use_cassette "omg_ami4ccm_last" do
        item = RelatonOmg::OmgBibliography.get "OMG AMI4CCM"
        expect(item).to be_instance_of RelatonOmg::OmgBibliographicItem
        file = "spec/fixtures/omg_ami4ccm_last.xml"
        xml = item.to_xml # bibdata: true
        File.write file, xml, encoding: "utf-8" unless File.exist? file
        expect(xml).to be_equivalent_to File.read(file, encoding: "utf-8").sub(
          %r{(?<=<fetched>)\d{4}-\d{2}-\d{2}}, Date.today.to_s
        )
        schema = Jing.new "grammars/relaton-omg-compile.rng"
        errors = schema.validate file
        expect(errors).to eq []
      end
    end

    it "get specification", vcr: "omg_uml_2.1.1_superstructure" do
      item = RelatonOmg::OmgBibliography.get "OMG UML 2.1.1 Superstructure"
      expect(item).to be_instance_of RelatonOmg::OmgBibliographicItem
      expect(item.docidentifier.first.id).to eq "OMG UML 2.1.1 Superstructure"
      expect(item.title.first.title.content).to eq "Unified Modeling Language: Superstructure"
      expect(item.date.first.type).to eq "published"
      expect(item.date.first.on).to eq "2007-07-01"
    end

    it "deals with non-existent document" do
      VCR.use_cassette "non_existed_doc" do
        expect do
          RelatonOmg::OmgBibliography.get "OMG NOTEXIST 1.1"
        end.to output(/\[relaton-omg\] INFO: \(OMG NOTEXIST 1\.1\) Not found\./).to_stderr_from_any_process
      end
    end

    it "deals with unavailable service" do
      io = double("io")
      expect(io).to receive(:status).and_return(["503", "Service Unavailable"]).at_least(:once)
      expect(OpenURI).to receive(:open_uri).and_raise OpenURI::HTTPError.new("Service Unavailable", io)
      expect do
        RelatonOmg::OmgBibliography.get "OMG AMI4CCM"
      end.to raise_error RelatonBib::RequestError
    end

    it "deals with incorrect reference" do
      item = RelatonOmg::OmgBibliography.get "OMG Model Driven Architecture Guide rev. 2.0"
      expect(item).to be_nil
    end

    it "convert from XML to Hash" do
      item = RelatonOmg::OmgBibliographicItem.from_xml "spec/fixtures/omg_ami4ccm_1_0.xml"
      hash = item.to_hash
      file = "spec/fixtures/omg_ami4ccm_1_0.yaml"
      File.write file, hash.to_yaml, encoding: "UTF-8" unless File.exist? file
      expect(hash).to eq YAML.load_file(file)
    end

    # it "warn if XML doesn't have bibitem or bibdata element" do
    #   item = ""
    #   expect { item = RelatonOmg::XMLParser.from_xml "" }.to output(/can't find bibitem/)
    #     .to_stderr_from_any_process
    #   expect(item).to be_nil
    # end

    it "create from YAML" do
      item = RelatonOmg::OmgBibliographicItem.from_yaml "spec/fixtures/omg_ami4ccm_1_0.yaml"
      expect(item.to_xml).to be_equivalent_to File.read(
        "spec/fixtures/omg_ami4ccm_1_0.xml", encoding: "UTF-8"
      )
    end
  end
end
