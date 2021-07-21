# frozen_string_literal: true

require "English"

Gem::Specification.new do |spec|
  spec.required_ruby_version = ">= 2.7"
  spec.name = "interactor"
  spec.version = "3.1.2"

  spec.author = "Collective Idea"
  spec.email = "info@collectiveidea.com"
  spec.description = "Interactor provides a common interface for performing complex user interactions."
  spec.summary = "Simple interactor implementation"
  spec.homepage = "https://github.com/collectiveidea/interactor"
  spec.license = "MIT"

  spec.files = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.test_files = spec.files.grep(/^spec/)

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
