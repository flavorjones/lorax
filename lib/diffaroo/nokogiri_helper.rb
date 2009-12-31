module Diffaroo
  module NokogiriHelper
    def self.uniquely_named_children_of(node)
      collect = {}
      node.children.each do |child|
        if collect.key?(child.name)
          collect[child.name] = nil
        else
          collect[child.name] = child
        end
      end
      collect.values.compact
    end
  end
end
