require "coveralls"
Coveralls.wear!

require "interactor"

Dir[File.expand_path("../support/*.rb", __FILE__)].each { |f| require f }
