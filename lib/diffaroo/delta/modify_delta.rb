module Diffaroo
  class ModifyDelta < Delta
    attr_accessor :node1, :node2

    def initialize(node1, node2)
      @node1 = node1
      @node2 = node2
    end
  end
end
