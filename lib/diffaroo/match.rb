module Diffaroo
  class Match
    attr_accessor :pair, :weight

    def initialize(node1, node2, weight)
      @pair = [node1, node2]
      @weight = weight
    end
  end
end
