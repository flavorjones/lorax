module Diffaroo
  class Match
    attr_accessor :pair, :weight

    def initialize(node1, node2, weight)
      @pair = [node1, node2]
      @weight = weight
    end

    def other(node)
      case node
      when pair.first then pair.last
      when pair.last then pair.first
      else nil
      end
    end
  end
end
