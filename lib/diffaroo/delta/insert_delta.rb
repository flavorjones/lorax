module Diffaroo
  class InsertDelta < Delta
    attr_accessor :operation, :node, :xpath

    def initialize(node, xpath)
      @node      = node
      @xpath     = xpath
    end

    def apply!(document)
      parent = document.at_xpath(xpath)
      raise NodeNotFoundError, xpath unless parent
      parent << node.dup # TODO: patch nokogiri to make this efficient
    end
  end
end

