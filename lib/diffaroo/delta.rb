module Diffaroo
  class Delta
    class NodeNotFound < RuntimeError ; end

    def apply!(document)
      raise NotImplementedError
    end
  end
end

require "diffaroo/delta/insert_delta"
