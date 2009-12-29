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

    def match(node)
      # TODO: needs spec
      @matches.each do |match|
        return match if match.pair.include?(node)
      end
      nil
    end

    def matches
      # TODO: do we need this method?
      @matches
    end

    def pairs
      # TODO: do we need this method?
      @matches.collect { |match| match.pair }
    end

    def matched?(node)
      # TODO: do we need this method?
      @matched_nodes.member? node
    end

    def complement(node)
      # TODO: do we need this method?
      # TODO: THIS NEEDS TO BE O(1)!!
      return nil unless matched?(node)
      @matches.each do |match|
        return *(match.pair - [node]) if match.pair.include?(node)
      end
      nil
    end

    def add(match)
      # TODO: do we need this method?
      match.pair.each { |node| @matched_nodes.add node }
      @matches << match
    end
  end
end
