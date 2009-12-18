require 'digest/sha1'

module Diffaroo
  class Signature
    SEP = "\0"

    attr_accessor :node, :hash, :nodes, :hashes, :weights

    def initialize(node=nil)
      @hashes  = {} # node => hash
      @nodes   = {} # hash => node
      @weights = {} # node => weight
      @node    = node
      @hash    = node ? node_hash(node) : nil
    end

    def node_hash(node)
      return @hashes[node] if @hashes.key?(node)
      raise ArgumentError, "node_hash expects a Node, but received #{node.inspect}" unless node.is_a?(Nokogiri::XML::Node)

      calculated_hash = \
        if node.text?
          Digest::SHA1.hexdigest(node.content)
        elsif node.element?
          children_hash = Digest::SHA1.hexdigest node.children       .collect { |child| node_hash(child) }        .join(SEP)
          attr_hash     = Digest::SHA1.hexdigest node.attributes.sort.collect { |k,v|   [k, v.value]     }.flatten.join(SEP)
          Digest::SHA1.hexdigest [node.name, attr_hash, children_hash].join(SEP)
        else
          raise ArgumentError, "node_hash expects a text node or element, but received #{node.type}"
        end

      node_weight(node)

      @nodes[calculated_hash]  = node
      @hashes[node]            = calculated_hash
    end

    def node_weight(node)
      return @weights[node] if @weights.key?(node)
      raise ArgumentError, "node_weight expects a Node, but received #{node.inspect}" unless node.is_a?(Nokogiri::XML::Node)

      calculated_weight = \
        if node.text?
          1 + Math.log(node.content.length)
        elsif node.element?
          node.children.inject(1) { |sum, child| sum += node_weight(child) }
        else
          raise ArgumentError, "node_weight expects a text node or element, but received #{node.type}"
        end

      @weights[node] = calculated_weight
    end
  end
end
