require "English"

Gem::Specification.new do |spec|
  spec.name = "interactor"
  spec.version = "3.1.2"

  spec.author = "Collective Idea"
  spec.email = "info@collectiveidea.com"
  spec.description = "Interactor provides a common interface for performing complex user interactions."
  spec.summary = "Simple interactor implementation"
  spec.homepage = "https://github.com/collectiveidea/interactor"
  spec.license = "MIT"

  spec.test_files = spec.files.grep(/^spec/)

  spec.required_ruby_version = ">= 2.1"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.3"
  spec.add_development_dependency "rubocop", "~> 0.47.1"
end
