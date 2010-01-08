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
      candidates = match_set.signature2.nodes(sig1) || []
      candidates.reject! { |node| match_set.match(node) }

      if candidates.empty?
        node1.children.each do |child|
          match_recursively(match_set, child)
        end
        if match = match_set.match(node1)
          downward_match(match.pair.first, match.pair.last, match_set)
        end
      else
        upward_matches = candidates.collect do |node2|
          upward_match(node1, node2, match_depth(node2, match_set.signature2))
        end
        longest_trail = upward_matches.max { |a, b| a.length <=> b.length }
        longest_trail.each do |ancestral_match|
          match_set.add ancestral_match
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
      # TODO: OMG! MY EYES ARE BLEEDING! REFACTOR ME AND OPTIMIZE ME!
      children_set1 = collect_children_by_name(node1.children, match_set)
      children_set2 = collect_children_by_name(node2.children, match_set)

      children_set1.each do |name1, children1|
        children_set2.each do |name2, children2|
          next unless name1 == name2
          children1.each do |child1|
            children2.each do |child2|
              if node1.children.index(child1) == node2.children.index(child2)
                match_set.add Match.new(child1, child2)
                downward_match(child1, child2, match_set)
              end
            end
          end
        end
      end
    end

    def self.match_depth(node, sig)
      depth = 1 + Math.log(sig.size) * sig.weight(node) / sig.weight
      # puts "diffaroo: debug: #{__FILE__}:#{__LINE__}: depth #{depth} = 1 + #{Math.log(sig.size)} * #{sig.weight(node)} / #{sig.weight}"
      depth.to_i
    end

    def self.collect_children_by_name(node_set, match_set)
      collection = {}
      node_set.each do |child|
        next if match_set.match(child)
        (collection[child.name] ||= []) << child
      end
      collection
    end
  end
end
