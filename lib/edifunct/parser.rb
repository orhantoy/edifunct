# frozen_string_literal: true
require "edifunct/tokenizer"
require "edifunct/segment_group"

module Edifunct
  # The main entry point to converting a raw EDIFACT message into a structured object.
  # The structure is dictated by the provided schema.
  class Parser
    def initialize(message, schema:, tokenizer: nil)
      @message = message
      @schema = schema
      @tokenizer = tokenizer || Tokenizer.for_message(message)
    end

    def as_root_group(root_group_tag = "<root>")
      @segments = @tokenizer.as_segments(@message)

      SegmentGroup.new(root_group_tag).tap do |root_group|
        parse_group(root_group, schema)
      end
    end

    private

    attr_reader :schema, :segments

    def parse_group(parent_group, group_schema)
      group_schema.each do |schema_entry|
        Utils::stringify_hash_keys!(schema_entry)
        case schema_entry.fetch("type")
        when "segment"
          if current_segment_is?(schema_entry.fetch("segment_tag"))
            parent_group.add_segment(segments.shift)
            parent_group.add_segment(segments.shift) while schema_entry["repeat"] && current_segment_is?(schema_entry.fetch("segment_tag"))
          end
        when "segment_group"
          while current_segment_is?(schema_entry.fetch("content").fetch(0).fetch("segment_tag"))
            group = parent_group.create_group(schema_entry.fetch("group_name"))
            parse_group(group, schema_entry.fetch("content"))
          end
        end
      end
    end

    def current_segment_is?(tag)
      current_segment && current_segment.tag == tag
    end

    def current_segment
      segments[0]
    end
  end
end
