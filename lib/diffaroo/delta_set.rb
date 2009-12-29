module Diffaroo
  class DeltaSet
    attr_accessor :match_set, :deltas

    def initialize(match_set)
      raise ArgumentError, "DeltaSet.new expects a MatchSet but received a #{match_set.class}" unless match_set.is_a?(MatchSet)
      @match_set = match_set
      @deltas = []
      generate_deltas
    end

    def add(delta)
      @deltas << delta
    end

    def apply(document)
      apply! document.dup
    end

    def apply!(document)
      deltas.each do |delta|
        delta.apply! document
      end
      document
    end

    private

    def generate_deltas
      generate_inserts_and_moves_recursively match_set.signature2.root
      # generate_deletes_recursively
    end

    def generate_inserts_and_moves_recursively node
      match = match_set.match node
      if match.nil?
        add InsertDelta.new(node, node.parent.path)
      end
      # return if match.perfect?
      # create an update delta
      node.children.each { |child| generate_inserts_and_moves_recursively child }
    end

    # def generate_deletes_recursively
    # end
  end
end
