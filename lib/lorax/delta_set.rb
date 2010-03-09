module Lorax
  class DeltaSet
    attr_accessor :deltas

    def initialize
      @deltas = []
    end

    def add(delta)
      @deltas << delta
    end

    def apply(document)
      apply! document.dup
    end

    def apply!(document)
      deltas.each do |delta|
        delta.apply! document
      end
      document
    end
  end
end
