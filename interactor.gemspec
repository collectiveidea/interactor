# encoding: utf-8

Gem::Specification.new do |spec|
  spec.name    = "interactor"
  spec.version = "2.0.0"

  spec.author      = "Collective Idea"
  spec.email       = "info@collectiveidea.com"
  spec.description = "Interactor provides a common interface for performing complex interactions in a single request."
  spec.summary     = "Simple interactor implementation"
  spec.homepage    = "https://github.com/collectiveidea/interactor"
  spec.license     = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(/^spec/)
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10.1"
end
