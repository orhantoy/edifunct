RSpec.describe Edifunct::Tokenizer do
  describe ".for_message" do

    context "when UNA header is present" do
      let(:edifact_message) do
        <<~EDIFACT
        UNA;-:! "
        EDIFACT
      end

      it "creates an instance of tokenizer with expected delimiters" do
        tokenizer = described_class.for_message(edifact_message)

        expect(tokenizer.release_character).to eq '!'
        expect(tokenizer.segment_terminator).to eq '"'
        expect(tokenizer.data_element_separator).to eq '-'
        expect(tokenizer.component_data_element_separator).to eq ';'
      end
    end

    context "when UNA header is missing" do

      it "creates an instance of tokenizer with default delimiters" do
        tokenizer = described_class.for_message("")

        expect(tokenizer.release_character).to eq '?'
        expect(tokenizer.segment_terminator).to eq '\''
        expect(tokenizer.data_element_separator).to eq '+'
        expect(tokenizer.component_data_element_separator).to eq ':'
      end
    end
  end

  describe "#as_segments" do
    let(:tokenizer) { described_class.new }
    let(:edifact_message) do
      <<~EDIFACT
        UNB+UNOC:1+Sender+Recipient+20180120:1307+31'
        UNH+465+IFTSTA:D:10B:UN'
      EDIFACT
    end

    it "parses the expected segments from the EDIFACT message" do
      segments = tokenizer.as_segments(edifact_message)

      expect(segments.count).to eq 2
      expect(segments.map(&:tag)).to eq %w[UNB UNH]
    end
  end

  describe "#decode_value" do
    let(:tokenizer) { described_class.new }
    let(:value_to_decode) { raise }
    subject { tokenizer.decode_value(value_to_decode) }

    context "when some characters in value are escaped" do
      let(:value_to_decode) { "Hello?:World??" }
      it { is_expected.to eq "Hello:World?" }
    end

    context "when no characters are escaped" do
      let(:value_to_decode) { "Hello World!" }
      it { is_expected.to eq "Hello World!" }
    end
  end
end
