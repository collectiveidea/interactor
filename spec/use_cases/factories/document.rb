# frozen_string_literal: true

module Factories
  class Document
    attr_reader :data
    attr_reader :output
    
    def initialize(data)
      @data = data
    end

    def transform
      @output = @data
    end
  end
end