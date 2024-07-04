require_relative "lib/relaton_omg/version"

Gem::Specification.new do |spec|
  spec.name          = "relaton-omg"
  spec.version       = RelatonOmg::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = "RelatonOmg: retrieve OMG Standards for bibliographic "\
                       "using the IsoBibliographicItem model"
  spec.description   = "RelatonOmg: retrieve OMG Standards for bibliographic "\
                       "using the IsoBibliographicItem model"
  spec.homepage      = "https://github.com/relaton/relaton-ogn"
  spec.license       = "BSD-2-Clause"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/relaton/relaton-ogn"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "relaton-bib", "~> 1.19.0"
end
