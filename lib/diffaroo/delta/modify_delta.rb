module Diffaroo
  class ModifyDelta < Delta
    attr_accessor :node1, :node2

    def initialize(node1, node2)
      @node1 = node1
      @node2 = node2
    end

    def apply!(doc)
      node = doc.at_xpath(node1.path)
      raise NodeNotFoundError, xpath unless node

      if node.text?
        node.content = node2.content
      else
        attributes = attributes_hash(node)
        attributes2 = attributes_hash(node2)
        if attributes != attributes2
          attributes .each { |name, value| node.remove_attribute(name) }
          attributes2.each { |name, value| node[name] = value }
        end
      end
    end

    private

    def attributes_hash(node)
      # lame.
      node.attributes.inject({}) { |hash, attr| hash[attr.first] = attr.last.value ; hash }
    end
  end
end
