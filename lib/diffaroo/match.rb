module Diffaroo
  class Match
    attr_accessor :pair, :parent_offset

    def initialize(node1, node2, parent_offset)
      @pair = [node1, node2]
      @parent_offset = parent_offset
    end
  end
end
