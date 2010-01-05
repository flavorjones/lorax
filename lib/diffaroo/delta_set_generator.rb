module Diffaroo
  module DeltaSetGenerator
    def self.generate_delta_set match_set
      delta_set = DeltaSet.new
      generate_inserts_and_moves_recursively delta_set, match_set, match_set.signature2.root
      # generate_deletes_recursively
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
        end
      else
        # TODO: node.parent.children.index(node)) !? demeter would be furious.
        delta_set.add InsertDelta.new(node, node.parent.path, node.parent.children.index(node))
      end
    end

    # def generate_deletes_recursively
    # end
  end
end
