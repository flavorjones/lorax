module Diffaroo
  module FastMatcher
    def self.match(doc1, doc2)
      match_set = MatchSet.new(doc1, doc2)
      match_recursively match_set, match_set.signature1.root
      match_set
    end

    private

    def self.match_recursively(match_set, node1)
      return if match_set.match(node1)
      sig1       = match_set.signature1.signature(node1) # assumes node1 is in signature1
      candidates = match_set.signature2.nodes(sig1)

      if candidates
        upward_matches = candidates.collect do |node2|
          upward_match(node1, node2, match_depth(node2, match_set.signature2))
        end
        longest_trail = upward_matches.max { |a, b| a.length <=> b.length }
        longest_trail.each do |ancestral_match|
          match_set.add ancestral_match
        end
      else
        node1.children.each do |child|
          match_recursively(match_set, child)
        end
        if match = match_set.match(node1)
          downward_match(match.pair.first, match.pair.last, match_set)
        end
      end
    end

    def self.upward_match(node1, node2, max_depth)
      matches = [Match.new(node1, node2, :perfect => true)]
      curr1, curr2 = node1.parent, node2.parent
      1.upto(max_depth) do
        break unless curr1.name == curr2.name && ! curr1.is_a?(Nokogiri::XML::Document)
        matches << Match.new(curr1, curr2)
        curr1, curr2 = curr1.parent, curr2.parent
      end
      matches
    end

    def self.downward_match(node1, node2, match_set)
      children1 = NokogiriHelper.uniquely_named_children_of(node1)
      children2 = NokogiriHelper.uniquely_named_children_of(node2)
      children1.each do |child1|
        matching_child2 = children2.detect do |child2| 
          child1.name == child2.name && match_set.match(child1).nil? && match_set.match(child2).nil?
        end
        if matching_child2
          match_set.add Match.new(child1, matching_child2)
        end
      end
    end

    def self.match_depth(node, sig)
      depth = 1 + Math.log(sig.size) * sig.weight(node) / sig.weight
      # puts "diffaroo: debug: #{__FILE__}:#{__LINE__}: depth #{depth} = 1 + #{Math.log(sig.size)} * #{sig.weight(node)} / #{sig.weight}"
      depth.to_i
    end
  end
end
