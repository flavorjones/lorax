module Diffaroo
  module FastMatcher
    def FastMatcher.match(matcher)
      match_recursively matcher, matcher.signature1.root
    end

    private

    def FastMatcher.match_recursively(matcher, node1)
      sig1       = matcher.signature1.signature(node1) # assumes node1 is in signature1
      candidates = matcher.signature2.nodes(sig1)

      if candidates
        parent_matches = candidates.collect do |node2|
          match_parents_recursively(node1, node2, match_depth(node2, matcher.signature2))
        end
        parent_matches.compact!
        if ! parent_matches.empty?
          matcher.add parent_matches.max {|a, b| a.parent_offset <=> b.parent_offset}
          return true # matching a parent should abort recursing through children
        else
          matcher.add Match.new(node1, candidates.first, 0)
        end
      else
        node1.children.each do |child|
          break if match_recursively(matcher, child)
        end
      end
      false
    end

    def FastMatcher.match_parents_recursively(node1, node2, depth, max_depth=depth)
      if depth >= 1 && node1.parent.name == node2.parent.name && ! node1.parent.is_a?(Nokogiri::XML::Document)
        more_parents = match_parents_recursively(node1.parent, node2.parent, depth-1, max_depth)
        return more_parents || Match.new(node1.parent, node2.parent, max_depth + 1 - depth)
      end
      nil
    end

    def FastMatcher.match_depth(node, sig)
      d = 1 + Math.log(sig.size) * sig.weight(node) / sig.weight
      # puts "diffaroo: debug: #{__FILE__}:#{__LINE__}: depth #{d} = 1 + #{Math.log(sig.size)} * #{sig.weight(node)} / #{sig.weight}"
      d.to_i
    end
  end
end
