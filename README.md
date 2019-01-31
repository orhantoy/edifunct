# Edifunct

Fun with EDIFACT :tada:

EDIFACT files consist of segments and extracting the segments themselves is not too complex.
But when segments are being grouped in segment groups and nested segment groups, it would require having an additional, manual parsing step after extracting the segments.
This gem makes this easy by parsing the EDIFACT file according to a simple schema which you provide alongside the EDIFACT file.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'edifunct'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install edifunct

## Usage

An example EDIFACT file:

```
UNB+UNOC:4+5790000110018:14+SEAFT.AFT006+20151012:1354+31'
UNH+45689+IFTSTA:D:10B:UN'
BGM+77+YSTSE-39237+9'
DTM+137:20150820:203'
DTM+2:20150820:102'
DTM+234:20150820:102'
CNI+1+DSVS41599'
CNT+7:9:KGM'
STS++Z1+5+8+38+108'
RFF+BN:123456'
RFF+ZTF:9F'
RFF+CU:8008331140'
RFF+AAS:7481947187'
RFF+SRN:57065930000021747'
RFF+AAM:40157065930100420983'
RFF+ASI:FM807287'
DTM+334:201508201020:203'
FTX+AHN+++Collect remarks1:2:3:4:5'
NAD+AP'
CTA+GR+:DONALD DRIVER'
NAD+CZ+++UAE LOGISTICS AB+BOX 1001:SE-164 21 KISTA+KISTA++164 21+SE'
NAD+CN+++SIERSEMA+KEURWEG 2:.:NL 5145 NX 5145 NX WAALWIJK+5145 NX WAALWIJK++5145 NX+NL'
NAD+DP+++BYGMA KOLDING+GEJLHAVEGÅRD 2 A:DK-6000 KOLDING+KOLDING++6000+DK'
NAD+PW+++NAUTISK TEKNIK APS+FARUMVEJ 107, GANLØSE:V/MARTIN KRISTENSEN:DK-3660 STENLØSE+STENLØSE++3660+DK'
NAD+ST+123456++ALFA LAVAL KOLDING A/S+31 ALBUEN:DK-6000 KOLDING+KOLDING++6000+DK'
NAD+SF+789456++SANISTAL SIA+Tiraines iela 9+Riga++1058+LV'
LOC+Z01+SELAA::6:SELAA LANDSKRONA'
GID+1+1:PK'
LOC+14+LANDSKRONA'
MEA+WT+AAB+KGM:100'
MEA+WT+ADZ+KGM:90'
MEA+VOL++MTQ:2'
MEA+LMT++MTR:4'
MEA+CT+SQ+PLL:5'
DIM+1+MTR:0.2:0.1:0.1'
PCI+17'
GIN+BN+00073000093496312546:00073000090414361624+00073000090414361631:00073000090414361648+00073000090414361655:00073000093496312539+00073000123496312546:00073000053496312546+00073000093496312789:00073000093496312684'
PCI+18'
GIN+AW+373999991234567899:373323995756893927+373323995780867383:373323995756893927+373323995859384889:373323995859360043+373323995859387804:373323995859387811+373323995859387842:373323995859392068'
UNT+18+45689'
UNZ+1+31'
```

A schema can be described entirely in JSON. An example schema for the EDIFACT file above could look like this:

```json
[
  { "type": "segment", "segment_tag": "UNB" },
  { "type": "segment", "segment_tag": "UNH" },
  { "type": "segment", "segment_tag": "BGM" },
  { "type": "segment", "segment_tag": "DTM", "repeat": true },
  {
    "type": "segment_group",
    "group_name": "SG13",
    "content": [
      { "type": "segment", "segment_tag": "CNI" },
      { "type": "segment", "segment_tag": "CNT", "repeat": true },
      {
        "type": "segment_group",
        "group_name": "SG14",
        "content": [
          { "type": "segment", "segment_tag": "STS" },
          { "type": "segment", "segment_tag": "RFF", "repeat": true },
          { "type": "segment", "segment_tag": "DTM", "repeat": true },
          { "type": "segment", "segment_tag": "FTX", "repeat": true },
          {
            "type": "segment_group",
            "group_name": "SG15",
            "content": [
              { "type": "segment", "segment_tag": "NAD" },
              {
                "type": "segment_group",
                "group_name": "SG16",
                "content": [
                  { "type": "segment", "segment_tag": "CTA" }
                ]
              }
            ]
          },
          { "type": "segment", "segment_tag": "LOC" },
          {
            "type": "segment_group",
            "group_name": "SG23",
            "content": [
              { "type": "segment", "segment_tag": "GID" },
              { "type": "segment", "segment_tag": "LOC", "repeat": true },
              {
                "type": "segment_group",
                "group_name": "SG24",
                "content": [
                  { "type": "segment", "segment_tag": "MEA" }
                ]
              },
              {
                "type": "segment_group",
                "group_name": "SG25",
                "content": [
                  { "type": "segment", "segment_tag": "DIM" }
                ]
              },
              {
                "type": "segment_group",
                "group_name": "SG26",
                "content": [
                  { "type": "segment", "segment_tag": "PCI" },
                  { "type": "segment", "segment_tag": "GIN", "repeat": true }
                ]
              }
            ]
          }
        ]
      }
    ]
  },
  { "type": "segment", "segment_tag": "UNT" },
  { "type": "segment", "segment_tag": "UNZ" }
]
```

Now we are ready to parse the EDIFACT file:

```ruby
# iftsta_example_as_string: EDIFACT file (String)
# iftsta_schema: Schema (Array<Hash>)

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
# => {"8008331140"=>[{:status=>"Z1", :event_time=>"201508201020"}]}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/orhantoy/edifunct.
