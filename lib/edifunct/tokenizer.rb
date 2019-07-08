# frozen_string_literal: true

require "edifunct/segment"

module Edifunct
  # Tokenizer is responsible for splitting message into segments, data elements and components.
  class Tokenizer
    class << self
      def for_message(_edifact_message)
        # TODO: Should check if the message starts with `UNA`, and then extract the different separator/terminator settings to be used for initializing the tokenizer.
        new
      end
    end

    attr_reader :release_character, :segment_terminator, :data_element_separator, :component_data_element_separator

    def initialize(release_character: "?", segment_terminator: "'", data_element_separator: "+", component_data_element_separator: ":")
      @release_character = release_character
      @segment_terminator = segment_terminator
      @data_element_separator = data_element_separator
      @component_data_element_separator = component_data_element_separator
    end

    def as_segments(message_as_string)
      strip_service_string_advice(message_as_string).split(segment_regexp).map do |raw_segment|
        segment_tag, data_elements = split_segment(raw_segment)

        Segment.new(tag: segment_tag, raw_segment: raw_segment, data_elements: data_elements)
      end
    end

    def split_segment(raw_segment)
      segment_without_terminator = raw_segment.chomp(@segment_terminator)
      segment_tag, *data_elements_as_strings = segment_without_terminator.split(data_element_regexp)

      data_elements = data_elements_as_strings.map do |data_element_as_string|
        data_element_as_string.split(component_data_element_regexp).map do |component|
          decode_value(component)
        end
      end

      [segment_tag, data_elements]
    end

    def decode_value(encoded_value)
      encoded_value.gsub(escape_value_regexp, '\1')
    end

    def formatted_segments_per_line(message_as_string)
      message_as_string.gsub(segment_regexp, "\n")
    end

    private

    def escape_value_regexp
      @escape_value_regexp ||= Regexp.new("#{Regexp.escape(@release_character)}(#{Regexp.escape(@release_character)}|#{Regexp.escape(@segment_terminator)}|#{Regexp.escape(@data_element_separator)}|#{Regexp.escape(@component_data_element_separator)})")
    end

    def segment_regexp
      @segment_regexp ||= Regexp.new("(?!#{Regexp.escape(@release_character)})(?<=#{Regexp.escape(@segment_terminator)})\\s*")
    end

    def data_element_regexp
      @data_element_regexp ||= Regexp.new("(?!#{Regexp.escape(@release_character)})#{Regexp.escape(@data_element_separator)}")
    end

    def component_data_element_regexp
      @component_data_element_regexp ||= Regexp.new("(?!#{Regexp.escape(@release_character)})#{Regexp.escape(@component_data_element_separator)}")
    end

    SERVICE_STRING_ADVICE_REGEXP = /\A\s*UNA.{6}\s*/

    # Strips the optional UNA segment, also known as the Service String Advice.
    def strip_service_string_advice(message_as_string)
      message_as_string.sub(SERVICE_STRING_ADVICE_REGEXP, '')
    end
  end
end
