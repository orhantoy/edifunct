# frozen_string_literal: true

module Edifunct
  # Represents a segment in an EDIFACT document/message.
  class Segment
    attr_reader :tag, :raw_segment, :data_elements

    def initialize(tag:, raw_segment:, data_elements:)
      @tag = tag
      @raw_segment = raw_segment
      @data_elements = data_elements
    end
  end
end
