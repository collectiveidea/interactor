# frozen_string_literal: true

guard :bundler, cmd: "bundle install" do
  watch("Gemfile")
  watch("interactor.gemspec")
end

group :green_pass_then_cop, halt_on_fail: true do
  guard :rspec, cmd: "bundle exec rspec -f doc" do
    require "guard/rspec/dsl"
    dsl = Guard::RSpec::Dsl.new(self)

    # RSpec files
    rspec = dsl.rspec
    watch(rspec.spec_helper) { rspec.spec_dir }
    watch(rspec.spec_support) { rspec.spec_dir }
    watch(rspec.spec_files)

    # Ruby files
    ruby = dsl.ruby
    dsl.watch_spec_files_for(ruby.lib_files)
    watch(%r{^lib/interactor/(.+)\.rb$}) { |m| "spec/unit/#{m[1]}_spec.rb" }
    watch(%r{^lib/interactor/commands/(.+)\.rb$}) { |m| "spec/unit/commands/#{m[1]}_spec.rb" }
  end

  guard :rubocop, all_on_start: false, cli: ["--format", "clang"] do
    watch(/{.+\.rb$/)
    watch(%r{(?:.+/)?\.rubocop(?:_todo)?\.yml$}) { |m| File.dirname(m[0]) }
  end
end
