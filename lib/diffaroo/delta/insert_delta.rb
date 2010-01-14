module Diffaroo
  class InsertDelta < Delta
    attr_accessor :node, :xpath, :position

    def initialize(node, xpath, position)
      @node     = node
      @xpath    = xpath
      @position = position
    end

    def apply!(document)
      # TODO: patch nokogiri to make inserting node copies efficient
      parent = document.at_xpath(xpath)
      raise NodeNotFoundError, xpath unless parent
      insert_node(node.dup, parent, position)
    end
  end
end
