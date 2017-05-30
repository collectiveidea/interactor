if ENV["CODECLIMATE_REPO_TOKEN"]
  require "simplecov"
  SimpleCov.start
end

require "interactor"
require "interactor/test_helpers"

Dir[File.expand_path("../support/*.rb", __FILE__)].each { |f| require f }
