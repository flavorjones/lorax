module Lorax
  class DeleteDelta < Delta
    attr_accessor :node

    def initialize(node)
      @node = node
    end

    def apply!(document)
      target = document.at_xpath(node.path)
      raise NodeNotFoundError, xpath unless target
      target.unlink
    end

    def descriptor
      [:delete, {:xpath => node.path, :content => node.to_s}]
    end

    def to_s
      response = []
      response << "--- #{node.path}"
      response << "+++"
      response << context_before(node)
      response << node.to_html.gsub(/^/,'- ').strip
      response << context_after(node)
      response.join("\n")
    end
  end
end
