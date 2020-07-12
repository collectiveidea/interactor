require "English"

Gem::Specification.new do |spec|
  spec.name    = "interactor"
  spec.version = "4.0.0"

  spec.author = "Collective Idea"
  spec.email = "info@collectiveidea.com"
  spec.description = "Interactor provides a common interface for performing complex user interactions."
  spec.summary = "Simple interactor implementation"
  spec.homepage = "https://github.com/collectiveidea/interactor"
  spec.license = "MIT"

  spec.test_files = spec.files.grep(/^spec/)

  spec.required_ruby_version = ">= 2.5"

  spec.add_development_dependency "rake", "~> 13.0"
end
