module Diffaroo
  class MatchOptimizer
    def MatchOptimizer.match(matcher)
      match_recursively(matcher, matcher.signature1.root)
    end

    private

    def MatchOptimizer.match_recursively(matcher, node1)
      node1.children.each { |child| match_recursively(matcher, child) } # bottom-up
      return if matcher.matched?(node1)
      possible_matches = []
      node1.children.select {|child| matcher.matched?(child) }.each do |child|
        other = matcher.complement(child)
        if other && other.parent.name == node1.name && ! other.parent.is_a?(Nokogiri::XML::Document)
          possible_matches << Match.new(node1, other.parent, matcher.signature1.weight(child)) # assumes node1 is in signature1
        end            
      end
      if (match = possible_matches.max {|a, b| a.weight <=> b.weight})
        matcher.add match
      end
    end
  end
end
