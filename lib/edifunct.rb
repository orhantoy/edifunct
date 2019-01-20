# frozen_string_literal: true

require "edifunct/version"
require "edifunct/parser"
require "edifunct/tokenizer"

# Top-level Edifunct namespace with short-hands methods to parse EDIFACT documents.
module Edifunct
  class << self
    def parse(edifact_message, schema:)
      parser = Parser.new(edifact_message, schema: schema)
      parser.as_root_group
    end

    def parse_file(file_args, schema:)
      edifact_message = File.read(*Array(file_args))
      parse(edifact_message, schema: schema)
    end

    def as_segments(edifact_message)
      tokenizer = Tokenizer.for_message(edifact_message)
      tokenizer.as_segments(edifact_message)
    end
  end
end
