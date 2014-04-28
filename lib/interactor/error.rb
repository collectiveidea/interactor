module Interactor
  class Error < StandardError; end
  class Success < Error; end
  class Failure < Error; end
end
