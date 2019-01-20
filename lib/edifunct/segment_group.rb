# frozen_string_literal: true

require "edifunct/segment"

module Edifunct
  # Represents the logical grouping of segments.
  class SegmentGroup
    attr_reader :tag
    attr_reader :children

    def initialize(tag)
      @tag = tag
      @children = []

      @child_segment_map = Hash.new { |hash, key| hash[key] = [] }
      @child_segment_group_map = Hash.new { |hash, key| hash[key] = [] }
    end

    def add_segment(segment)
      @children << segment
      @child_segment_map[segment.tag] << segment

      segment
    end

    def create_group(segment_group_tag)
      segment_group = SegmentGroup.new(segment_group_tag)

      @children << segment_group
      @child_segment_group_map[segment_group.tag] << segment_group

      segment_group
    end

    def lookup_groups(segment_group_tag)
      @child_segment_group_map[segment_group_tag]
    end

    def lookup_group(segment_group_tag)
      lookup_groups(segment_group_tag).first
    end

    def lookup_segments(segment_tag)
      @child_segment_map[segment_tag]
    end

    def lookup_segment(segment_tag, &block)
      if block_given?
        lookup_segments(segment_tag).find(&block)
      else
        lookup_segments(segment_tag).first
      end
    end

    def print_with_structure
      _print_with_structure(self)
    end

    private

    def _print_with_structure(group, padding: "")
      group.children.each do |child|
        case child
        when Segment
          print "#{padding}#{child.raw_segment}\n"
        when SegmentGroup
          print "#{padding}#{child.tag}\n"
          _print_with_structure(child, padding: padding + "  ")
        end
      end
    end
  end
end
