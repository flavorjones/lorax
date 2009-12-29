module Diffaroo
  class Match
    attr_accessor :pair

    def initialize(node1, node2)
      @pair = [node1, node2]
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
