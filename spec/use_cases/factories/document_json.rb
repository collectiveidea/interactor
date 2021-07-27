# frozen_string_literal: true

require 'json'
require_relative './document'

module Factories
  class DocumentJson < Factories::Document
    def transform
      @output = JSON.generate(data)
    end
  end
end