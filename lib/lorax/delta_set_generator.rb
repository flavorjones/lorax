module Lorax
  module DeltaSetGenerator
    def self.generate_delta_set match_set
      delta_set = DeltaSet.new
      generate_inserts_and_moves_recursively delta_set, match_set, match_set.signature2.root
      generate_deletes_recursively delta_set, match_set, match_set.signature1.root
      delta_set
    end

    private

    def self.generate_inserts_and_moves_recursively delta_set, match_set, node
      match = match_set.match node
      if match
        if ! match.perfect?
          if match_set.signature1.monogram(match.pair.first) != match_set.signature2.monogram(match.pair.last)
            delta_set.add ModifyDelta.new(match.pair.first, match.pair.last)
          end
          node.children.each { |child| generate_inserts_and_moves_recursively delta_set, match_set, child }
        else
          # TODO MIKE NEED TO CHECK PARENT PATHS, NOT IDENTITY. THEY ARE DIFFERENT DOCUMENTS. SHIT.
          if match.pair.first.parent != match.pair.last.parent || position_of(match.pair.first) != position_of(match.pair.last)
            puts "#{node.path} #{match.pair.first.parent.inspect} != #{match.pair.last.parent.inspect} || #{position_of(match.pair.first) != position_of(match.pair.last)}"
            delta_set.add ModifyDelta.new(match.pair.first, match.pair.last)
          end
        end
      else
        delta_set.add InsertDelta.new(node, node.parent.path, position_of(node))
      end
    end

    def self.generate_deletes_recursively delta_set, match_set, node
      match = match_set.match(node)
      if match
        return if match.perfect?
        node.children.each { |child| generate_deletes_recursively delta_set, match_set, child }
      else
        delta_set.add DeleteDelta.new(node)
      end
    end

    def self.position_of(node)
      node.parent.children.index(node)
    end
  end
end
