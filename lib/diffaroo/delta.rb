module Diffaroo
  class Delta
    class InsertParentNotFound < RuntimeError ; end

    attr_accessor :operation, :node, :xpath

    def initialize(operation, node, xpath)
      @operation = operation
      @node      = node
      @xpath     = xpath
    end

    def apply!(document)
      parent = document.xpath(xpath)
      raise InsertParentNotFound, xpath unless parent
      parent << node.dup # TODO: patch nokogiri to make this efficient
    end
  end
end
