require 'digest/sha1'

module Diffaroo
  class Signature
    SEP = "\0"

    def initialize(node=nil)
      @signatures = {} # node      => signature
      @nodes      = {} # signature => [node, ...]
      @weights    = {} # node      => weight
      @size       = 0
      @node       = node
      signature(node) if node
    end

    def root
      @node
    end

    def nodes(sig=nil)
      sig ? @nodes[sig] : @node
    end

    def size
      @size
    end

    def signature(node=@node)
      return @signatures[node] if @signatures.key?(node)
      raise ArgumentError, "signature expects a Node, but received #{node.inspect}" unless node.is_a?(Nokogiri::XML::Node)

      calculated_sig = \
        if node.text? || node.cdata? || node.comment?
          hashify node.content
        elsif node.element?
          children_sig = hashify(node.children       .collect { |child| signature(child) })
          attr_sig     = hashify(node.attributes.sort.collect { |k,v|   [k, v.value]     }.flatten)
          hashify(node.name, attr_sig, children_sig)
        else
          raise ArgumentError, "signature expects a text node or element, but received #{node.class}"
        end

      @size += 1
      weight(node)

      (@nodes[calculated_sig] ||= []) << node
      @signatures[node]               =  calculated_sig
    end

    def weight(node=@node)
      return @weights[node] if @weights.key?(node)
      raise ArgumentError, "weight expects a Node, but received #{node.inspect}" unless node.is_a?(Nokogiri::XML::Node)

      calculated_weight = \
        if node.text? || node.cdata? || node.comment?
          1 + Math.log(node.content.length)
        elsif node.element?
          node.children.inject(1) { |sum, child| sum += weight(child) }
        else
          raise ArgumentError, "weight expects a text node or element, but received #{node.class}"
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
