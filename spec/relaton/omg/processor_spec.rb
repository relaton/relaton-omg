require "relaton/omg/processor"

describe Relaton::Omg::Processor do
  subject(:processor) { described_class.new }

  it "initializes attributes" do
    expect(processor.short).to eq :relaton_omg
    expect(processor.prefix).to eq "OMG"
    expect(processor.defaultprefix).to eq(/^OMG /)
    expect(processor.idtype).to eq "OMG"
  end

  it "gets a document", vcr: "omg_ami4ccm_1_0" do
    result = processor.get("OMG AMI4CCM 1.0", nil, {})
    expect(result).to be_instance_of Relaton::Omg::ItemData
    expect(result.docidentifier.first.content).to eq "OMG AMI4CCM 1.0"
  end

  it "creates from XML" do
    xml = File.read "spec/fixtures/omg_ami4ccm_1_0.xml", encoding: "UTF-8"
    item = processor.from_xml(xml)
    expect(item).to be_instance_of Relaton::Omg::ItemData
    expect(item.docidentifier.first.content).to eq "OMG AMI4CCM 1.0"
  end

  it "creates from YAML" do
    yaml = File.read "spec/fixtures/omg_ami4ccm_1_0.yaml", encoding: "UTF-8"
    item = processor.from_yaml(yaml)
    expect(item).to be_instance_of Relaton::Omg::ItemData
    expect(item.docidentifier.first.content).to eq "OMG AMI4CCM 1.0"
  end

  it "returns grammar hash" do
    hash = processor.grammar_hash
    expect(hash).to be_instance_of String
    expect(hash.size).to eq 32
  end
end
