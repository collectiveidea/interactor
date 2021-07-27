# frozen_string_literal: true

module Factories
  class DocumentFactory < BaseFactory
    delegate :type, :data, to: :context

    def instance
      guard(:data)

      case type
      when :json
        DocumentJson.new(data)
      when :xml
        DocumentXml.new(data)
      else
        Document.new(data)
      end
    end 
  end
end