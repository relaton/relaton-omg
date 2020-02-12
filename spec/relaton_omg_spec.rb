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

  context "get OMG document" do
    it "get specific version" do
      VCR.use_cassette "omg_ami4ccm_1_0" do
        item = RelatonOmg::OmgBibliography.get "OMG AMI4CCM 1.0"
        expect(item).to be_instance_of RelatonOmg::OmgBibliographicItem
        file = "spec/fixtures/omg_ami4ccm_1_0.xml"
        xml = item.to_xml # bibdata: true
        File.write file, xml, encoding: "utf-8" unless File.exist? file
        expect(xml).to be_equivalent_to File.read(file, encoding: "utf-8").sub(
          %r{(?<=<fetched>)\d{4}-\d{2}-\d{2}}, Date.today.to_s
        )
        schema = Jing.new "spec/fixtures/bibdata.rng"
        errors = schema.validate file
        expect(errors).to eq []
      end
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
        schema = Jing.new "spec/fixtures/bibdata.rng"
        errors = schema.validate file
        expect(errors).to eq []
      end
    end
  end
end
