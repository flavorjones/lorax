require 'digest/sha1'

module Lorax
  class Signature
    SEP = "\0"

    def initialize(node=nil)
      @signatures = {} # node      => signature
      @monograms  = {} # node      => monogram (signature not including children)
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
      sig ? @nodes[sig] : [@node]
    end

    def size
      @size
    end

    def signature(node=@node)
      return @signatures[node] if @signatures.key?(node)
      raise ArgumentError, "signature expects a Node, but received #{node.inspect}" unless node.is_a?(Nokogiri::XML::Node)

      if node.text?
        content = node.content.strip
        if content.empty?
          return nil
        else
          monogram     = signature = hashify(content)
        end
      elsif node.cdata? || node.comment?
        monogram     = signature = hashify(node.content)
      elsif node.type == Nokogiri::XML::Node::ENTITY_REF_NODE
        monogram     = signature = hashify(node.to_html)
      elsif node.element?
        children_sig = hashify(node.children       .collect { |child| signature(child) }.compact)
        attr_sig     = hashify(node.attributes.sort.collect { |k,v|   [k, v.value]     }.flatten)
        monogram     = hashify(node.name, attr_sig)
        signature    = hashify(node.name, attr_sig, children_sig)
      else
        raise ArgumentError, "signature expects an element, text, cdata or comment node, but received #{node.class}"
      end

      @size += 1
      weight(node)

      (@nodes[signature] ||= []) << node
      @monograms[node]           =  monogram
      @signatures[node]          =  signature
    end

    def weight(node=@node)
      return @weights[node] if @weights.key?(node)
      raise ArgumentError, "weight expects a Node, but received #{node.inspect}" unless node.is_a?(Nokogiri::XML::Node)

      if node.text?
        content = node.content.strip
        if content.empty?
          calculated_weight = 0
        else          
          calculated_weight = 1 + Math.log(content.length)
        end
      elsif node.cdata? || node.comment?
        calculated_weight = 1 + Math.log(node.content.length)
      elsif node.type == Nokogiri::XML::Node::ENTITY_REF_NODE
        calculated_weight = 1
      elsif node.element?
        calculated_weight = node.children.inject(1) { |sum, child| sum += weight(child) }
      else
        raise ArgumentError, "weight expects an element, text, cdata or comment node, but received #{node.class}"
      end

      @weights[node] = calculated_weight
    end

    def monogram(node=@node)
      return @monograms[node] if @monograms.key?(node)
      signature(node)
      @monograms[node]
    end

    def set_signature(node, value) # :nodoc: for testing
      (@nodes[value] ||= []) << node
      @signatures[node]      =  value
    end

    def set_weight(node, value) # :nodoc: for testing
      @weights[node] = value
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
