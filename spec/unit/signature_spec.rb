require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Lorax::Signature do
  WHITESPACES = ["\n"," ","\t","\r","\f"]

  def assert_node_signature_equal(node1, node2)
    Lorax::Signature.new(node1).signature.should == Lorax::Signature.new(node2).signature
  end

  def assert_node_signature_not_equal(node1, node2)
    Lorax::Signature.new(node1).signature.should_not == Lorax::Signature.new(node2).signature
  end

  describe ".new" do
    it "accepts nil" do
      proc { Lorax::Signature.new }.should_not raise_error
    end

    it "does not call signature if param is nil" do
      mock.instance_of(Lorax::Signature).signature(42).never
      Lorax::Signature.new(nil)
    end

    it "calls signature if a param is non-nil" do
      mock.instance_of(Lorax::Signature).signature(42).once
      Lorax::Signature.new(42)
    end
  end

  describe "#root" do
    it "returns the subtree root" do
      doc = xml { root { a1 "hello" } }
      node = doc.at_css("a1")
      sig = Lorax::Signature.new(node)
      sig.root.should == node
    end
  end

  describe "#nodes" do
    it "returns an array of nodes matching the signature" do
      doc = xml { root {
          a1 "hello"
          a1 "hello"
          a1 "hello"
        } }
      nodes    = doc.css("a1")
      doc_sig  = Lorax::Signature.new(doc.root)
      node_sig = Lorax::Signature.new(nodes.first)
      doc_sig.nodes(node_sig.signature).should =~ nodes.to_a
    end

    it "returns the node if I pass nil" do
      doc = xml { root {
          a1 "hello1"
          a1 "hello2"
          a1 "hello3"
        } }
      nodes    = doc.css("a1")
      doc_sig  = Lorax::Signature.new(doc.root)
      node_sig = Lorax::Signature.new(nodes.first)
      doc_sig.nodes(nil).should == [doc.root]
    end
  end

  describe "#size" do
    it "returns the total number of nodes in the subtree" do
      doc      = xml { root { a1 "hello" } }
      node     = doc.at_css("a1")
      doc_sig  = Lorax::Signature.new(doc.root)
      doc_sig.size.should == 3 # root, a1, hello
    end
  end

  describe "#set_signature" do
    it "assigns values such that signature and nodes return the proper thing" do
      signature = Lorax::Signature.new
      signature.set_signature(:foo, "a")
      signature.set_signature(:bar, "a")
      signature.set_signature(:bazz, "b")
      signature.signature(:foo).should == "a"
      signature.signature(:bar).should == "a"
      signature.signature(:bazz).should == "b"
      signature.nodes("a").should =~ [:foo, :bar]
      signature.nodes("b").should == [:bazz]
    end
  end

  describe "#set_weight" do
    it "assigns values such that weight returns the proper thing" do
      signature = Lorax::Signature.new
      signature.set_weight(:foo, 2.2)
      signature.weight(:foo).should == 2.2
    end
  end

  describe "#signature" do
    context "passed no argument" do
      it "returns the subtree root's signature" do
        doc = xml { root { a1 "hello" } }
        sig = Lorax::Signature.new(doc.root)
        sig.signature.should == sig.signature(doc.root)
      end
    end

    context "passed a node" do
      it "returns the node's signature" do
        doc      = xml { root { a1 "hello" } }
        node     = doc.at_css("a1")
        doc_sig  = Lorax::Signature.new(doc.root)
        node_sig = Lorax::Signature.new(node)
        doc_sig.signature(node).should == node_sig.signature
      end
    end

    context "passed a non-Node" do
      it "raises an error" do
        proc { Lorax::Signature.new.signature(42) }.should raise_error(ArgumentError, /signature expects a Node/)
      end
    end

    context "passed a cdata Node" do
      it "treats it like a leaf text node" do
        doc = xml { root { cdata "hello" } }
        node = doc.root.children.first
        doc_sig  = Lorax::Signature.new(doc.root)
        node_sig = Lorax::Signature.new(node)
        doc_sig.signature(node).should == node_sig.signature
      end
    end

    context "passed a comment Node" do
      it "treats it like a leaf text node" do
        doc = Nokogiri::XML "<root><!-- hello --></root>"
        node = doc.root.children.first
        doc_sig  = Lorax::Signature.new(doc.root)
        node_sig = Lorax::Signature.new(node)
        doc_sig.signature(node).should == node_sig.signature
      end
    end

    context "passed an entity reference Node" do
      it "treats it like a leaf text node" do
        doc = Nokogiri::XML %q(<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"><html><span>&nbsp;</span></html>)
        node = doc.at_css("span").children.first
        doc_sig  = Lorax::Signature.new(doc.root)
        node_sig = Lorax::Signature.new(node)
        doc_sig.signature(node).should == node_sig.signature
      end
    end

    context "passed an invalid Node" do
      it "raises an error" do
        doc = xml { root { a1("foo" => "bar") } }
        attr = doc.at_css("a1").attributes.first.last
        proc { Lorax::Signature.new.signature(attr) }.should raise_error(ArgumentError, /signature expects an element/) 
      end
    end

    it "hashes each node only once" do
      doc = xml { root { a1 { b1 { c1 "hello" } } } }
      node = doc.at_css "c1"
      mock.proxy.instance_of(Lorax::Signature).signature(anything).times(5)
      Lorax::Signature.new.signature(doc.root)
    end

    it "caches signaturees" do
      doc = xml { root { a1 { b1 { c1 "hello" } } } }
      node = doc.at_css "c1"
      mock.proxy.instance_of(Lorax::Signature).signature(anything).times(6)
      sig = Lorax::Signature.new
      sig.signature(doc.root)
      sig.signature(doc.root)
    end

    it "calculates weights along the way" do
      doc  = xml { root { a1 } }
      node = doc.at_css "a1"
      sig = Lorax::Signature.new
      mock(sig).weight(node)
      sig.signature(node)
    end

    context "passed a text Node" do
      it "returns equal signatures for identical text nodes" do
        doc = xml { root {
            span "hello"
            span "hello"
          } }
        assert_node_signature_equal(*doc.css("span").collect { |n| n.children.first })
      end

      it "returns inequal signatures for different text nodes" do
        doc = xml { root {
            span "hello"
            span "goodbye"
          } }
        assert_node_signature_not_equal(*doc.css("span").collect { |n| n.children.first })
      end

      it "ignores leading whitespace" do
        doc = xml { root {
            span "hello"
            span "#{WHITESPACES.join}hello"
          } }
        assert_node_signature_equal(*doc.css("span").collect { |n| n.children.first })
      end

      it "ignores trailing whitespace" do
        doc = xml { root {
            span "hello"
            span "hello#{WHITESPACES.join}"
          } }
        assert_node_signature_equal(*doc.css("span").collect { |n| n.children.first })
      end

      it "treats empty text nodes the same as no text node" do
        doc = xml { root {
            span WHITESPACES.join
            span
          } }
        assert_node_signature_equal(*doc.css("span"))
      end
    end

    context "elements with same name (with no attributes and no content)" do
      it "have equal signatures" do
        doc = xml { root { a1 ; a1 } }
        assert_node_signature_equal(*doc.css("a1"))
      end
    end

    context "elements with different names" do
      it "have inequal signatures" do
        doc = xml { root { a1 ; a2 } }
        assert_node_signature_not_equal doc.at_css("a1"), doc.at_css("a2")
      end
    end

    context "same elements in different docs" do
      it "have equal signatures" do
        doc1 = xml { root { a1 } }
        doc2 = xml { root { a1 } }
        assert_node_signature_equal doc1.at_css("a1"), doc2.at_css("a1")
      end
    end

    context "elements with same name and content (with no attributes)" do
      context "and content is the same" do
        it "have equal signatures" do
          doc = xml { root {
              a1 "hello"
              a1 "hello"
            } }
          assert_node_signature_equal(*doc.css("a1"))
        end
      end

      context "and content is not the same" do
        it "have inequal signatures" do
          doc = xml { root {
              a1 "hello"
              a1 "goodbye"
            } }
          assert_node_signature_not_equal(*doc.css("a1"))
        end
      end
    end

    context "elements with same name and children (with no attributes)" do
      context "and children are in the same order" do
        it "have equal signatures" do
          doc = xml { root {
              a1 { b1 ; b2 }
              a1 { b1 ; b2 }
            } }
          assert_node_signature_equal(*doc.css("a1"))
        end
      end

      context "and children are not in the same order" do
        it "have inequal signatures" do
          doc = xml { root {
              a1 { b1 ; b2 }
              a1 { b2 ; b1 }
            } }
          assert_node_signature_not_equal(*doc.css("a1"))
        end
      end
    end

    context "elements with same name and same attributes (with no content)" do
      it "have equal signatures" do
        doc = xml { root {
            a1("foo" => "bar", "bazz" => "quux")
            a1("foo" => "bar", "bazz" => "quux")
          } }
        assert_node_signature_equal(*doc.css("a1"))
      end
    end

    context "elements with same name and different attributes (with no content)" do
      it "have inequal signatures" do
        doc = xml { root {
            a1("foo" => "bar", "bazz" => "quux")
            a1("foo" => "123", "bazz" => "456")
          } }
        assert_node_signature_not_equal(*doc.css("a1"))
      end
    end

    context "attributes reverse-engineered to be similar" do
      it "have inequal signatures" do
        doc = xml { root {
            a1("foo" => "bar#{Lorax::Signature::SEP}quux")
            a1("foo#{Lorax::Signature::SEP}bar" => "quux")
          } }
        assert_node_signature_not_equal(*doc.css("a1"))
      end
    end

    context "HTML" do
      it "should be case-insensitive" do
        doc1 = Nokogiri::HTML <<-EOH
        <html><body>
          <DIV FOO="BAR">hello</DIV>
        </body></html>
        EOH
        doc2 = Nokogiri::HTML <<-EOH
        <html><body>
          <div foo="BAR">hello</div>
        </body></html>
        EOH
        assert_node_signature_equal(doc1.at_css("body").children.first,
                                    doc2.at_css("body").children.first)
      end
    end
  end

  describe "#weight" do
    context "passed no argument" do
      it "returns the subtree root's weight" do
        doc      = xml { root { a1 { b1 { c1 { d1 } } } } }
        node     = doc.at_css("a1")
        doc_sig  = Lorax::Signature.new(doc.root)
        doc_sig.weight.should == 5
      end
    end

    context "passed a node" do
      it "returns the node's weight" do
        doc      = xml { root { a1 "hello" } }
        node     = doc.at_css("a1")
        doc_sig  = Lorax::Signature.new(doc.root)
        node_sig = Lorax::Signature.new(node)
        doc_sig.weight(node).should == node_sig.weight
      end
    end

    context "passed a non-Node" do
      it "raises an error" do
        proc { Lorax::Signature.new.weight(42) }.should raise_error(ArgumentError, /weight expects a Node/)
      end
    end

    context "passed a cdata Node" do
      it "treats it like a leaf text node" do
        doc = xml { root { cdata "hello" } }
        node = doc.root.children.first
        doc_sig  = Lorax::Signature.new(doc.root)
        node_sig = Lorax::Signature.new(node)
        doc_sig.weight(node).should == node_sig.weight
      end
    end

    context "passed a comment Node" do
      it "treats it like a leaf text node" do
        doc = Nokogiri::XML "<root><!-- hello --></root>"
        node = doc.root.children.first
        doc_sig  = Lorax::Signature.new(doc.root)
        node_sig = Lorax::Signature.new(node)
        doc_sig.weight(node).should == node_sig.weight
      end
    end

    context "passed an entity reference Node" do
      it "treats it like a leaf text node" do
        doc = Nokogiri::XML %q(<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"><html><span>&nbsp;</span></html>)
        node = doc.at_css("span").children.first
        doc_sig  = Lorax::Signature.new(doc.root)
        node_sig = Lorax::Signature.new(node)
        doc_sig.weight(node).should == node_sig.weight
      end
    end

    context "passed an invalid Node" do
      it "raises an error" do
        doc  = xml { root { a1("foo" => "bar") } }
        attr = doc.at_css("a1").attributes.first.last
        proc { Lorax::Signature.new.weight(attr) }.should raise_error(ArgumentError, /weight expects an element/) 
      end
    end

    it "weighs each node only once" do
      doc  = xml { root { a1 { b1 { c1 "hello" } } } }
      node = doc.at_css "c1"
      mock.proxy.instance_of(Lorax::Signature).weight(anything).times(5)
      Lorax::Signature.new.weight(doc.root)
    end

    it "caches weights" do
      doc  = xml { root { a1 { b1 { c1 "hello" } } } }
      node = doc.at_css "c1"
      mock.proxy.instance_of(Lorax::Signature).weight(anything).times(6)
      sig = Lorax::Signature.new
      sig.weight(doc.root)
      sig.weight(doc.root)
    end

    it "weighs empty nodes with no children as 1" do
      doc = xml { root { a1 } }
      sig = Lorax::Signature.new(doc.root)
      sig.weight(doc.at_css("a1")).should == 1
    end

    it "weighs nodes with children as 1 + sum(weight(children))" do
      doc = xml { root {
          a1 { b1 ; b2 }
          a2 { b1 ; b2 ; b3 ; b4 }
        } }
      sig = Lorax::Signature.new(doc.root)
      sig.weight(doc.at_css("a1")).should == 3
      sig.weight(doc.at_css("a2")).should == 5
      sig.weight.should == 9
    end

    describe "text nodes" do
      it "scores as 1 + log(length)" do
        doc = xml { root {
            a1 "x"
            a2("x" * 500)
            a3("x" * 50_000)
          } }
        sig = Lorax::Signature.new(doc.root)
        sig.weight(doc.at_css("a1")).should be_within(0.0005).of(2)
        sig.weight(doc.at_css("a2")).should be_within(0.0005).of(2 + Math.log(500))
        sig.weight(doc.at_css("a3")).should be_within(0.0005).of(2 + Math.log(50_000))
      end
    end
  end

  describe "#monogram" do
    context "passed no argument" do
      it "returns the subtree root's signature" do
        doc = xml { root { a1(:foo => :bar) } }
        sig = Lorax::Signature.new(doc.root)
        sig.monogram.should == sig.monogram(doc.root)
      end
    end

    context "passed a node" do
      it "returns the node's signature" do
        doc      = xml { root { a1(:foo => :bar) } }
        node     = doc.at_css("a1")
        doc_sig  = Lorax::Signature.new(doc.root)
        node_sig = Lorax::Signature.new(node)
        doc_sig.monogram(node).should == node_sig.monogram
      end
    end

    context "passed a non-Node" do
      it "raises an error" do
        proc { Lorax::Signature.new.monogram(42) }.should raise_error(ArgumentError, /signature expects a Node/)
      end
    end

    context "text nodes" do
      it "returns the signature as the monogram" do
        doc = xml { root { text "hello" } }
        node = doc.root.children.first
        sig = Lorax::Signature.new(doc.root)
        sig.monogram(node).should == sig.signature(node)
      end
    end

    context "element nodes" do
      it "is equal for nodes with equal names and attributes" do
        doc = xml { root {
            a1(:foo => :bar, :bazz => :quux) { text "hello" }
            a1(:foo => :bar, :bazz => :quux) { b1 }
            a1(:foo => :bar, :bazz => :quux)
          } }
        nodes = doc.css("a1")
        sig = Lorax::Signature.new(doc.root)
        sig.monogram(nodes[0]).should == sig.monogram(nodes[1])
        sig.monogram(nodes[1]).should == sig.monogram(nodes[2])
      end

      it "is inequal for nodes with different attributes" do
        doc = xml { root {
            a1(:foo => :bar)
            a1(:foo => :bar, :bazz => :quux)
          } }
        nodes = doc.css("a1")
        sig = Lorax::Signature.new(doc.root)
        sig.monogram(nodes[0]).should_not == sig.monogram(nodes[1])
      end
    end
  end
end
