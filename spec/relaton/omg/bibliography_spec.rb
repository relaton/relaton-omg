# frozen_string_literal: true

require "jing"

RSpec.describe Relaton::Omg do
  it "has a version number" do
    expect(Relaton::Omg::VERSION).not_to be_nil
  end

  it "returns grammar hash" do
    hash = described_class.grammar_hash
    expect(hash).to be_instance_of String
    expect(hash.size).to eq 32
  end
end

RSpec.describe Relaton::Omg::Bibliography do
  it "fetches specific version", vcr: "omg_ami4ccm_1_0" do
    expect do
      item = described_class.get "OMG AMI4CCM 1.0"
      expect(item).to be_instance_of Relaton::Omg::ItemData
      file = "spec/fixtures/omg_ami4ccm_1_0.xml"
      xml = item.to_xml
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

  it "fetches last version" do
    VCR.use_cassette "omg_ami4ccm_last" do
      item = described_class.get "OMG AMI4CCM"
      expect(item).to be_instance_of Relaton::Omg::ItemData
      file = "spec/fixtures/omg_ami4ccm_last.xml"
      xml = item.to_xml
      File.write file, xml, encoding: "utf-8" unless File.exist? file
      expect(xml).to be_equivalent_to File.read(file, encoding: "utf-8").sub(
        %r{(?<=<fetched>)\d{4}-\d{2}-\d{2}}, Date.today.to_s
      )
      schema = Jing.new "grammars/relaton-omg-compile.rng"
      errors = schema.validate file
      expect(errors).to eq []
    end
  end

  it "fetches specification", vcr: "omg_uml_2.1.1_superstructure" do
    item = described_class.get "OMG UML 2.1.1 Superstructure"
    expect(item).to be_instance_of Relaton::Omg::ItemData
    expect(item.docidentifier.first.content).to eq "OMG UML 2.1.1 Superstructure"
    expect(item.title.first.content).to eq "Unified Modeling Language: Superstructure"
    expect(item.date.first.type).to eq "published"
    expect(item.date.first.at.to_s).to eq "2007-07-01"
  end

  it "deals with non-existent document" do
    VCR.use_cassette "non_existed_doc" do
      expect do
        described_class.get "OMG NOTEXIST 1.1"
      end.to output(/\[relaton-omg\] INFO: \(OMG NOTEXIST 1\.1\) Not found\./).to_stderr_from_any_process
    end
  end

  it "deals with unavailable service" do
    agent = double("agent")
    expect(Mechanize).to receive(:new).and_return(agent)
    expect(agent).to receive(:open_timeout=).with(10)
    page = double("page", code: "503")
    expect(agent).to receive(:get).and_raise Mechanize::ResponseCodeError.new(page)
    expect do
      described_class.get "OMG AMI4CCM"
    end.to raise_error Relaton::RequestError
  end

  it "deals with incorrect reference" do
    item = described_class.get "OMG Model Driven Architecture Guide rev. 2.0"
    expect(item).to be_nil
  end

  it "converts from XML to Hash" do
    file = "spec/fixtures/omg_ami4ccm_1_0.xml"
    item = Relaton::Omg::Bibitem.from_xml File.read(file, encoding: "UTF-8")
    hash = YAML.safe_load Relaton::Omg::Item.to_yaml(item)
    yaml_file = "spec/fixtures/omg_ami4ccm_1_0.yaml"
    File.write yaml_file, hash.to_yaml, encoding: "UTF-8" unless File.exist? yaml_file
    expect(hash).to eq YAML.load_file(yaml_file)
  end

  it "creates from YAML" do
    yaml = File.read "spec/fixtures/omg_ami4ccm_1_0.yaml", encoding: "UTF-8"
    item = Relaton::Omg::Item.from_yaml yaml
    expect(item.to_xml).to be_equivalent_to File.read(
      "spec/fixtures/omg_ami4ccm_1_0.xml", encoding: "UTF-8",
    )
  end
end
