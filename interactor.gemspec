# encoding: utf-8

Gem::Specification.new do |spec|
  spec.name    = "interactor"
  spec.version = "3.1.1"

  spec.author      = "Collective Idea"
  spec.email       = "info@collectiveidea.com"
  spec.description = "Interactor provides a common interface for performing complex user interactions."
  spec.summary     = "Simple interactor implementation"
  spec.homepage    = "https://github.com/collectiveidea/interactor"
  spec.license     = "MIT"

  spec.files      = `git ls-files`.split($/)
  spec.test_files = spec.files.grep(/^spec/)

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
