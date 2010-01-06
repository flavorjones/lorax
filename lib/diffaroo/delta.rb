module Diffaroo
  class Delta
    class NodeNotFoundError < RuntimeError ; end

    def apply!(document)
      raise NotImplementedError, self.class.to_s
    end
  end
end

require "diffaroo/delta/insert_delta"
require "diffaroo/delta/modify_delta"
require "diffaroo/delta/delete_delta"
