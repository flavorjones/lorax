module Diffaroo
  class FastMatcher
    attr_accessor :match_set

    def initialize(doc1, doc2, dependency_injection={})
      @document1 = doc1
      @document2 = doc2
      @match_set = dependency_injection[:matcher_match_set] || MatchSet.new(doc1, doc2, dependency_injection)
    end

    def match
      match_node @document1.root
    end

    private

    def match_node(node1)
      return if match_set.match(node1)
      signature1 = match_set.signature1.signature(node1) # assumes node1 is in signature1
      candidates = match_set.signature2.nodes(signature1) || []
      candidates.reject! { |node| match_set.match(node) }

      if candidates.empty?
        node1.children.each do |child|
          match_node(child)
        end
        match = match_set.match(node1)
        propagate_to_children(match.pair.first, match.pair.last) if match
      else
        match_candidate(node1, candidates)
      end
      propagate_to_parent(node1) unless match_set.match(node1)
      match_set
    end

    def match_candidate(node1, candidates)
      ancestral_matches = candidates.collect do |node2|
        ancestral_match(node1, node2, depth(node2, match_set.signature2))
      end
      longest_trail = ancestral_matches.max { |a, b| a.length <=> b.length }
      longest_trail.each do |ancestral_match|
        match_set.add ancestral_match
      end
    end

    def ancestral_match(node1, node2, max_depth)
      matches = [Match.new(node1, node2, :perfect => true)]
      curr1, curr2 = node1.parent, node2.parent
      1.upto(max_depth) do
        break unless curr1.name == curr2.name && ! curr1.is_a?(Nokogiri::XML::Document)
        matches << Match.new(curr1, curr2)
        curr1, curr2 = curr1.parent, curr2.parent
      end
      matches
    end

    def propagate_to_parent(node1)
      node1.children.sort_by { |child| match_set.signature1.weight(child) }.reverse.each do |child|
        next unless match = match_set.match(child)
        match_parent = match.pair.last.parent
        if match_parent.name == node1.name
          match_set.add Match.new(node1, match_parent)
          return
        end
      end
    end

    def propagate_to_children(node1, node2)
      # TODO: OMG! MY EYES ARE BLEEDING! REFACTOR ME AND OPTIMIZE ME!
      children_set1 = collect_children_by_name(node1.children)
      children_set2 = collect_children_by_name(node2.children)

      children_set1.each do |name1, children1|
        children_set2.each do |name2, children2|
          next unless name1 == name2
          children1.each do |child1|
            children2.each do |child2|
              if node1.children.index(child1) == node2.children.index(child2)
                match_set.add Match.new(child1, child2)
                propagate_to_children(child1, child2)
              end
            end
          end
        end
      end
    end

    def depth(node, sig)
      depth = 1 + Math.log(sig.size) * sig.weight(node) / sig.weight
      # puts "diffaroo: debug: #{__FILE__}:#{__LINE__}: depth #{depth} = 1 + #{Math.log(sig.size)} * #{sig.weight(node)} / #{sig.weight}"
      depth.to_i
    end

    def collect_children_by_name(node_set)
      collection = {}
      node_set.each do |child|
        next if match_set.match(child)
        (collection[child.name] ||= []) << child
      end
      collection
    end
  end
end
