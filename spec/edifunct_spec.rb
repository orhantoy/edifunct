require "json"

RSpec.describe Edifunct do
  it "has a version number" do
    expect(Edifunct::VERSION).not_to be nil
  end

  it "parses the message according to the schema" do
    fixtures_dir = File.join(__dir__, "fixtures")
    iftsta_example_as_string = File.read(File.join(fixtures_dir, "IFTSTA_example.edi"), encoding: "ISO-8859-1")
    iftsta_schema = JSON.parse(File.read(File.join(fixtures_dir, "IFTSTA_schema.json")))

    iftsta_example = Edifunct.parse(iftsta_example_as_string, schema: iftsta_schema)
    expect(iftsta_example.lookup_groups("SG13").count).to eq 1

    sg13 = iftsta_example.lookup_groups("SG13")[0]
    expect(sg13.lookup_groups("SG14").count).to eq 1
  end

  it "parses the file according to the schema" do
    fixtures_dir = File.join(__dir__, "fixtures")
    iftsta_example_path = File.join(fixtures_dir, "IFTSTA_example.edi")
    iftsta_schema = JSON.parse(File.read(File.join(fixtures_dir, "IFTSTA_schema.json")))

    iftsta_example = Edifunct.parse_file([iftsta_example_path, encoding: "ISO-8859-1"], schema: iftsta_schema)
    expect(iftsta_example.lookup_groups("SG13").count).to eq 1

    sg13 = iftsta_example.lookup_groups("SG13")[0]
    expect(sg13.lookup_groups("SG14").count).to eq 1
  end

  it "splits the message into segments" do
    fixtures_dir = File.join(__dir__, "fixtures")
    iftsta_example_as_string = File.read(File.join(fixtures_dir, "IFTSTA_example.edi"), encoding: "ISO-8859-1")

    iftsta_example_segments = Edifunct.as_segments(iftsta_example_as_string)
    expect(iftsta_example_segments.count).to eq 41
  end

  it "splits a message with the Service String Advice into segments" do
    iftsta_example_as_string = <<~EDIFACT
      UNA:+.? '
      UNB+UNOC:1+Sender+Recipient+20180120:1307+31'
      UNH+465+IFTSTA:D:10B:UN'
    EDIFACT

    iftsta_example_segments = Edifunct.as_segments(iftsta_example_as_string)
    expect(iftsta_example_segments.count).to eq 2
    expect(iftsta_example_segments[0].tag).to eq "UNB"
  end
end
