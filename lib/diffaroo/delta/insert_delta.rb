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
      children = parent.children
      if children.empty? || position >= children.length
        parent << node.dup
      else
        children[position].add_previous_sibling(node.dup)
      end
    end
  end
end
