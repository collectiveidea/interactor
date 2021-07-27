# frozen_string_literal: true

# require 'nokogiri'
require_relative './document'

module Factories
  class DocumentXml < Factories::Document
    def transform
      @output = ['<root>', serialize(data), '</root>'].join()
    end

    private

    def serialize(object)
      object.map do |key, value|
        noderize(key, value)
      end.flatten
    end
  
    def noderize(key, value)
      if value.class == Hash
        node_value = serialize(value).join
        ["<#{key}>#{node_value}</#{key}>"]
      elsif value.class == Array
        nodes = value.map { |v| serialize(v).join() }
        nodes.map { |n| ["<#{key}>#{n}</#{key}>"] }
      else
        node_value = value.nil? ? "" : value
        ["<#{key}>#{node_value}</#{key}>"]
      end
  
      
    end
  end
end

# module Xml
#   extend self

  
# end

# puts Xml.serialize({
#   name: "Vinicius",
#   username: "vnbrs",
#   address: {
#     country: {
#       name: "Brazil",
#       dial_code: 55
#     },
#     street: "R Jose Ananias Mauad",
#     street_number: nil,
#   }
# })