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

  spec.files = `git ls-files`.split($INPUT_RECORD_SEPARATOR)

  spec.add_dependency "ostruct"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
