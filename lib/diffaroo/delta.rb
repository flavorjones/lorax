module Diffaroo
  class Delta
    class NodeNotFoundError < RuntimeError ; end

    def apply!(document)
      raise NotImplementedError
    end
  end
end

require "diffaroo/delta/insert_delta"
require "diffaroo/delta/modify_delta"
