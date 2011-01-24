module Lorax
  class Delta
    class NodeNotFoundError < RuntimeError ; end

    def apply!(document)
      raise NotImplementedError, self.class.to_s
    end

    def inspect
      "#<#{self.class.name}:#{sprintf("0x%x", object_id)} #{descriptor.inspect}>"
    end

    private

    def insert_node(node, parent, position)
      children = parent.children
      if children.empty? || position >= children.length
        parent << node.dup
      else
        children[position].add_previous_sibling(node.dup)
      end
    end

    def context_before node
      if node.previous_sibling
        node.previous_sibling.to_xml.gsub(/^/,'  ').rstrip
      else
        "  <#{node.parent.name}>"
      end
    end

    def context_after node
      if node.next_sibling
        node.next_sibling.to_xml.gsub(/^/,'  ').rstrip
      else
        "  </#{node.parent.name}>"
      end
    end
  end
end

require "lorax/delta/insert_delta"
require "lorax/delta/modify_delta"
require "lorax/delta/delete_delta"
