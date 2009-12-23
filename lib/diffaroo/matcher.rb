require "set"

module Diffaroo
  class Matcher
    # TODO: this class needs cleanup / refactoring.
    def initialize(doc1, doc2)
      @document1  = doc1
      @document2  = doc2
      @signature1 = Diffaroo::Signature.new(@document1.root)
      @signature2 = Diffaroo::Signature.new(@document2.root)
      @matches    = []
      @matched_nodes = Set.new
      match
    end

    def match
      match_recursively @document1.root
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

    private

    def add(match)
      match.pair.each { |node| @matched_nodes.add node }
      @matches << match
    end

    def match_recursively(node1)
      sig1       = @signature1.signature(node1) # assumes node1 is in document1
      candidates = @signature2.nodes(sig1)

      if candidates
        parent_matches = candidates.collect do |node2|
          match_parents_recursively(node1, node2, match_depth(node2, @signature2))
        end
        parent_matches.compact!
        if ! parent_matches.empty?
          add parent_matches.max {|a, b| a.parent_offset <=> b.parent_offset}
          return true # matching a parent should abort recursing through children
        else
          add Match.new(node1, candidates.first, 0)
        end
      else
        node1.children.each do |child|
          break if match_recursively(child)
        end
      end
      false
    end

    def match_parents_recursively(node1, node2, depth, max_depth=depth)
      if depth >= 1 && node1.parent.name == node2.parent.name && ! node1.parent.is_a?(Nokogiri::XML::Document)
        more_parents = match_parents_recursively(node1.parent, node2.parent, depth-1, max_depth)
        return more_parents || Match.new(node1.parent, node2.parent, max_depth + 1 - depth)
      end
      nil
    end

    def match_depth(node, sig)
      d = 1 + Math.log(sig.size) * sig.weight(node) / sig.weight
      # puts "diffaroo: debug: #{__FILE__}:#{__LINE__}: depth #{d} = 1 + #{Math.log(sig.size)} * #{sig.weight(node)} / #{sig.weight}"
      d.to_i
    end
  end
end
