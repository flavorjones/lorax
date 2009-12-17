require 'digest/sha1'

module Diffaroo
  class Signature
    SEP = "\0"

    attr_accessor :node, :hash, :hashes

    def initialize(node=nil)
      @hashes = {}
      @node   = node
      @hash   = node ? node_hash(node) : nil
    end

    def node_hash(node)
      return @hashes[node] if @hashes.key?(node)
      raise ArgumentError, "node_hash expects a Node, but received #{node.inspect}" unless node.is_a?(Nokogiri::XML::Node)

      @hashes[node] = \
        if node.text?
          Digest::SHA1.hexdigest(node.content)
        elsif node.element?
          children_hash = Digest::SHA1.hexdigest node.children       .collect { |child| node_hash(child) }        .join(SEP)
          attr_hash     = Digest::SHA1.hexdigest node.attributes.sort.collect { |k,v|   [k, v.value]     }.flatten.join(SEP)
          Digest::SHA1.hexdigest [node.name, attr_hash, children_hash].join(SEP)
        else
          raise ArgumentError, "node_hash expects a text node or element, but received #{node.type}"
        end
    end
  end
end
