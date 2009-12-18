
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
      hash  = @signature1.hashes[node1] # assumes node1 is in document1
      node2 = @signature2.nodes[hash]
      if node2
        @matches << [node1, node2]
      else
        node1.children.each { |child| match_recursively child }
      end
    end
  end
end
