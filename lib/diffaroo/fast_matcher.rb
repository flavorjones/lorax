module Diffaroo
  module FastMatcher
    def FastMatcher.match(doc1, doc2)
      match_set = MatchSet.new(doc1, doc2)
      match_recursively match_set, match_set.signature1.root
      match_set
    end

    private

    def FastMatcher.match_recursively(match_set, node1)
      sig1       = match_set.signature1.signature(node1) # assumes node1 is in signature1
      candidates = match_set.signature2.nodes(sig1)

      if candidates
        upward_matches = candidates.collect do |node2|
          upward_match(node1, node2, match_depth(node2, match_set.signature2))
        end
        longest_trail = upward_matches.max { |a, b| a.length <=> b.length }
        longest_trail.each do |match|
          match_set.add match
        end
        return true if longest_trail.length > 1 # matching a parent should abort recursing through children
      else
        node1.children.each do |child|
          break if match_recursively(match_set, child)
        end
      end
      false
    end

    def FastMatcher.upward_match(node1, node2, max_depth)
      matches = [Match.new(node1, node2)]
      curr1, curr2 = node1.parent, node2.parent
      1.upto(max_depth) do
        break unless curr1.name == curr2.name && ! curr1.is_a?(Nokogiri::XML::Document)
        matches << Match.new(curr1, curr2)
        curr1, curr2 = curr1.parent, curr2.parent
      end
      matches
    end

    def FastMatcher.match_depth(node, sig)
      depth = 1 + Math.log(sig.size) * sig.weight(node) / sig.weight
      # puts "diffaroo: debug: #{__FILE__}:#{__LINE__}: depth #{depth} = 1 + #{Math.log(sig.size)} * #{sig.weight(node)} / #{sig.weight}"
      depth.to_i
    end
  end
end
