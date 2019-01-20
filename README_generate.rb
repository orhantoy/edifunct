require "bundler/setup"
require "json"
require "edifunct"

puts "# Edifunct"
puts
puts <<-MARKDOWN
Fun with EDIFACT :tada:

EDIFACT files consist of segments and extracting the segments themselves is not too complex.
But when segments are being grouped in segment groups and nested segment groups, it would require having an additional, manual parsing step after extracting the segments.
This gem makes this easy by parsing the EDIFACT file according to a simple schema which you provide alongside the EDIFACT file.
MARKDOWN

puts "\n## Installation"
puts
puts <<-MARKDOWN
Add this line to your application's Gemfile:

```ruby
gem 'edifunct'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install edifunct
MARKDOWN

fixtures_dir = File.join(__dir__, "spec", "fixtures")
iftsta_example_as_string = File.read(File.join(fixtures_dir, "IFTSTA_example.edi"), encoding: "ISO-8859-1")
iftsta_schema_json = File.read(File.join(fixtures_dir, "IFTSTA_schema.json"))
iftsta_schema = JSON.parse(iftsta_schema_json)

puts "\n## Usage"
puts
puts "An example EDIFACT file:"
puts
puts "```"
print iftsta_example_as_string
puts "```"
puts
puts "A schema can be described entirely in JSON. An example schema for the EDIFACT file above could look like this:"
puts
puts "```json"
print iftsta_schema_json
puts "```"
puts
puts "Now we are ready to parse the EDIFACT file:"
puts
puts "```ruby"
puts "# iftsta_example_as_string: EDIFACT file (String)"
puts "# iftsta_schema: Schema (Array<Hash>)"
puts

prog = <<-PROG
iftsta_example = Edifunct.parse(iftsta_example_as_string, schema: iftsta_schema)
iftsta_example.lookup_groups('SG13').each_with_object({}) do |group, consignments|
  sg14 = group.lookup_group('SG14')
  next unless sg14

  rff_cu_record = sg14.lookup_segment('RFF') { |s| s.data_elements[0] && s.data_elements[0][0] == 'CU' }
  next unless rff_cu_record

  dtm_record = sg14.lookup_segment('DTM')
  next unless dtm_record

  sts_record = sg14.lookup_segment('STS')
  next unless sts_record

  consignment_ref = rff_cu_record.data_elements[0][1]
  consignments[consignment_ref] = [
    {
      status: sts_record.data_elements[1][0],
      event_time: dtm_record.data_elements[0][1],
    }
  ]
end
PROG

print prog
consignments = eval prog
puts "# => #{consignments.inspect}"

puts "```"

puts "\n## Development"
puts
puts <<-MARKDOWN
After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
MARKDOWN

puts "\n## Contributing"
puts
puts <<-MARKDOWN
Bug reports and pull requests are welcome on GitHub at https://github.com/orhantoy/edifunct.
MARKDOWN
