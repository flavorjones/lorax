require 'digest/sha1'

module Diffaroo
  class Signature
    SEP = "\0"

    def initialize(node=nil)
      @hashes  = {} # node => hash
      @nodes   = {} # hash => [node, ...]
      @weights = {} # node => weight
      @size    = 0
      @node    = node
      hash(node) if node
    end

    def root
      @node
    end

    def nodes(hash=nil)
      hash ? @nodes[hash] : @node
    end

    def size
      @size
    end

    def hash(node=@node)
      return @hashes[node] if @hashes.key?(node)
      raise ArgumentError, "hash expects a Node, but received #{node.inspect}" unless node.is_a?(Nokogiri::XML::Node)

      calculated_hash = \
        if node.text?
          hashify node.content
        elsif node.element?
          children_hash = hashify(node.children       .collect { |child| hash(child)  })
          attr_hash     = hashify(node.attributes.sort.collect { |k,v|   [k, v.value] }.flatten)
          hashify(node.name, attr_hash, children_hash)
        else
          raise ArgumentError, "hash expects a text node or element, but received #{node.type}"
        end

      @size += 1
      weight(node)

      (@nodes[calculated_hash] ||= []) << node
      @hashes[node]                    =  calculated_hash
    end

    def weight(node=@node)
      return @weights[node] if @weights.key?(node)
      raise ArgumentError, "weight expects a Node, but received #{node.inspect}" unless node.is_a?(Nokogiri::XML::Node)

      calculated_weight = \
        if node.text?
          1 + Math.log(node.content.length)
        elsif node.element?
          node.children.inject(1) { |sum, child| sum += weight(child) }
        else
          raise ArgumentError, "weight expects a text node or element, but received #{node.type}"
        end

      @weights[node] = calculated_weight
    end

    private

    def hashify(*args)
      if args.length == 1
        if args.first.is_a?(Array)
          Digest::SHA1.hexdigest args.first.join(SEP)
        else
          Digest::SHA1.hexdigest args.first
        end
      else
        Digest::SHA1.hexdigest args.join(SEP)
      end
    end
  end
end
