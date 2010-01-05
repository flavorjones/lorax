module Diffaroo
  class DeleteDelta < Delta
    attr_accessor :node

    def initialize(node)
      @node = node
    end
  end
end
