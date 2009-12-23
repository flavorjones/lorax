require "set"

module Diffaroo
  class MatchSet
    attr_accessor :signature1, :signature2

    def initialize(doc1, doc2)
      @document1  = doc1
      @document2  = doc2
      @signature1 = Diffaroo::Signature.new(@document1.root)
      @signature2 = Diffaroo::Signature.new(@document2.root)
      @matches    = []
      @matched_nodes = Set.new
    end

    def matches
      @matches
    end

    def pairs
      @matches.collect { |match| match.pair }
    end

    def matched?(node)
      @matched_nodes.member? node
    end

    def complement(node)
      # TODO: THIS NEEDS TO BE O(1)!!
      @matches.each do |match|
        return *(match.pair - [node]) if match.pair.include?(node)
      end
      nil
    end

    def add(match)
      match.pair.each { |node| @matched_nodes.add node }
      @matches << match
    end
  end
end
