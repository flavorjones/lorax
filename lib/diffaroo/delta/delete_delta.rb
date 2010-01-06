module Diffaroo
  class DeleteDelta < Delta
    attr_accessor :node

    def initialize(node)
      @node = node
    end

    def apply!(document)
      target = document.at_xpath(node.path)
      raise NodeNotFoundError, xpath unless target
      target.unlink
    end
  end
end
