# frozen_string_literal: true

require 'pry'
require 'active_support'
require 'active_support/core_ext'
require 'active_support/core_ext/module/delegation'
require "interactor"


Dir[File.expand_path("support/*.rb", __dir__)].sort.each { |f| require f }
Dir[File.expand_path("use_cases/**/*.rb", __dir__)].sort.each { |f| require f }

RSpec.configure do |config|
  config.filter_run_when_matching :focus

#   config.expect_with :rspec do |c|
#     c.syntax = :expect
#   end
end
