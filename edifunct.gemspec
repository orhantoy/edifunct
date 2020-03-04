# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "edifunct/version"

Gem::Specification.new do |spec|
  spec.name          = "edifunct"
  spec.version       = Edifunct::VERSION
  spec.licenses      = ["MIT"]
  spec.authors       = ["Orhan Toy"]
  spec.email         = ["toyorhan@gmail.com"]

  spec.summary       = 'A schema-based EDIFACT parser'
  spec.description   = 'Edifunct provides an easy way to structurally parse an EDIFACT file based on a simple schema'
  spec.homepage      = 'https://github.com/orhantoy/edifunct'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "> 1.17.0"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec_junit_formatter", "~> 0.4.0"
end
