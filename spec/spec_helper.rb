if ENV["TRAVIS"]
  require "coveralls"
  Coveralls.wear!
end

require "interactor"

Dir[File.expand_path("../support/*.rb", __FILE__)].each { |f| require f }
