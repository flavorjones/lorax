module Diffaroo
  class Matcher
    attr_accessor :matches

    def initialize(doc1, doc2)
      @document1  = doc1
      @document2  = doc2
      @signature1 = Diffaroo::Signature.new(@document1.root)
      @signature2 = Diffaroo::Signature.new(@document2.root)
      @matches    = []
      match
    end

    def match
      match_recursively @document1.root
    end

    private

    def match_recursively(node1)
      hash  = @signature1.hash(node1) # assumes node1 is in document1
      nodes2 = @signature2.nodes(hash)
      if nodes2
        node2 = nodes2.first
        if match_parents_recursively(node1, node2, match_depth(node2, @signature2))
          true # matching a parent should abort recursing through children
        else
          @matches << [node1, node2]
          false
        end
      else
        node1.children.each do |child|
          break if match_recursively(child)
        end
        false
      end
    end

    def match_parents_recursively(node1, node2, depth)
      if depth >= 1 && node1.parent.name == node2.parent.name && ! node1.parent.is_a?(Nokogiri::XML::Document)
        unless match_parents_recursively(node1.parent, node2.parent, depth-1)
          @matches << [node1.parent, node2.parent]
        end
        return true
      end
      return false
    end

    def match_depth(node, sig)
      # puts "diffaroo: debug: #{__FILE__}:#{__LINE__}: depth #{d} = 1 + #{Math.log(sig.size)} * #{sig.weight(node)} / #{sig.weight}"
      1 + Math.log(sig.size) * sig.weight(node) / sig.weight
    end
  end
end
