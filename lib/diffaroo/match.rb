module Diffaroo
  class Match
    attr_accessor :pair

    def initialize(node1, node2, options={})
      @pair    = [node1, node2]
      @perfect = options[:perfect] ? true : false
    end

    def perfect?
      @perfect
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
