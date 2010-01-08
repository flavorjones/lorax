require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Diffaroo::Signature do
  def assert_node_signature_equal(node1, node2)
    Diffaroo::Signature.new(node1).signature.should == Diffaroo::Signature.new(node2).signature
  end

  def assert_node_signature_not_equal(node1, node2)
    Diffaroo::Signature.new(node1).signature.should_not == Diffaroo::Signature.new(node2).signature
  end

  describe ".new" do
    it "accepts nil" do
      proc { Diffaroo::Signature.new }.should_not raise_error
    end

    it "does not call signature if param is nil" do
      mock.instance_of(Diffaroo::Signature).signature(42).never
      Diffaroo::Signature.new(nil)
    end

    it "calls signature if a param is non-nil" do
      mock.instance_of(Diffaroo::Signature).signature(42).once
      Diffaroo::Signature.new(42)
    end
  end

  describe "#signatures" do
    it "returns the signatures hash, primarily for testing purposes" do
      doc = xml { root { a1 } }
      node = doc.at_css("a1")
      signature = Diffaroo::Signature.new(node)
      signature.signatures[node].should == signature.signature(node)
    end
  end

  describe "#root" do
    it "returns the subtree root" do
      doc = xml { root { a1 "hello" } }
      node = doc.at_css("a1")
      sig = Diffaroo::Signature.new(node)
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
      doc_sig  = Diffaroo::Signature.new(doc.root)
      node_sig = Diffaroo::Signature.new(nodes.first)
      doc_sig.nodes(node_sig.signature).should =~ nodes.to_a
    end
  end

  describe "#size" do
    it "returns the total number of nodes in the subtree" do
      doc      = xml { root { a1 "hello" } }
      node     = doc.at_css("a1")
      doc_sig  = Diffaroo::Signature.new(doc.root)
      doc_sig.size.should == 3 # root, a1, hello
    end
  end

  describe "#signature" do
    context "passed no argument" do
      it "returns the subtree root's signature" do
        doc = xml { root { a1 "hello" } }
        sig = Diffaroo::Signature.new(doc.root)
        sig.signature.should == sig.signature(doc.root)
      end
    end

    context "passed a node" do
      it "returns the node's signature" do
        doc      = xml { root { a1 "hello" } }
        node     = doc.at_css("a1")
        doc_sig  = Diffaroo::Signature.new(doc.root)
        node_sig = Diffaroo::Signature.new(node)
        doc_sig.signature(node).should == node_sig.signature
      end
    end

    context "passed a non-Node" do
      it "raises an error" do
        proc { Diffaroo::Signature.new.signature(42) }.should raise_error(ArgumentError, /signature expects a Node/)
      end
    end

    context "passed a cdata Node" do
      it "treats it like a leaf text node" do
        doc = xml { root { cdata "hello" } }
        node = doc.root.children.first
        doc_sig  = Diffaroo::Signature.new(doc.root)
        node_sig = Diffaroo::Signature.new(node)
        doc_sig.signature(node).should == node_sig.signature
      end
    end

    context "passed a comment Node" do
      it "treats it like a leaf text node" do
        doc = Nokogiri::XML "<root><!-- hello --></root>"
        node = doc.root.children.first
        doc_sig  = Diffaroo::Signature.new(doc.root)
        node_sig = Diffaroo::Signature.new(node)
        doc_sig.signature(node).should == node_sig.signature
      end
    end

    context "passed an entity reference Node" do
      it "treats it like a leaf text node" do
        doc = Nokogiri::XML %q(<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"><html><span>&nbsp;</span></html>)
        node = doc.at_css("span").children.first
        doc_sig  = Diffaroo::Signature.new(doc.root)
        node_sig = Diffaroo::Signature.new(node)
        doc_sig.signature(node).should == node_sig.signature
      end
    end

    context "passed an invalid Node" do
      it "raises an error" do
        doc = xml { root { a1("foo" => "bar") } }
        attr = doc.at_css("a1").attributes.first.last
        proc { Diffaroo::Signature.new.signature(attr) }.should raise_error(ArgumentError, /signature expects an element/) 
      end
    end

    it "hashes each node only once" do
      doc = xml { root { a1 { b1 { c1 "hello" } } } }
      node = doc.at_css "c1"
      mock.proxy.instance_of(Diffaroo::Signature).signature(anything).times(5)
      Diffaroo::Signature.new.signature(doc.root)
    end

    it "caches signaturees" do
      doc = xml { root { a1 { b1 { c1 "hello" } } } }
      node = doc.at_css "c1"
      mock.proxy.instance_of(Diffaroo::Signature).signature(anything).times(6)
      sig = Diffaroo::Signature.new
      sig.signature(doc.root)
      sig.signature(doc.root)
    end

    it "calculates weights along the way" do
      doc  = xml { root { a1 } }
      node = doc.at_css "a1"
      sig = Diffaroo::Signature.new
      mock(sig).weight(node)
      sig.signature(node)
    end

    context "identical text nodes" do
      it "have equal signatures" do
        doc = xml { root {
            span "hello"
            span "hello"
          } }
        assert_node_signature_equal(*doc.css("span").collect { |n| n.children.first })
      end
    end

    context "different text nodes" do
      it "have inequal signatures" do
        doc = xml { root {
            span "hello"
            span "goodbye"
          } }
        assert_node_signature_not_equal(*doc.css("span").collect { |n| n.children.first })
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
            a1("foo" => "bar#{Diffaroo::Signature::SEP}quux")
            a1("foo#{Diffaroo::Signature::SEP}bar" => "quux")
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
        doc_sig  = Diffaroo::Signature.new(doc.root)
        doc_sig.weight.should == 5
      end
    end

    context "passed a node" do
      it "returns the node's weight" do
        doc      = xml { root { a1 "hello" } }
        node     = doc.at_css("a1")
        doc_sig  = Diffaroo::Signature.new(doc.root)
        node_sig = Diffaroo::Signature.new(node)
        doc_sig.weight(node).should == node_sig.weight
      end
    end

    context "passed a non-Node" do
      it "raises an error" do
        proc { Diffaroo::Signature.new.weight(42) }.should raise_error(ArgumentError, /weight expects a Node/)
      end
    end

    context "passed a cdata Node" do
      it "treats it like a leaf text node" do
        doc = xml { root { cdata "hello" } }
        node = doc.root.children.first
        doc_sig  = Diffaroo::Signature.new(doc.root)
        node_sig = Diffaroo::Signature.new(node)
        doc_sig.weight(node).should == node_sig.weight
      end
    end

    context "passed a comment Node" do
      it "treats it like a leaf text node" do
        doc = Nokogiri::XML "<root><!-- hello --></root>"
        node = doc.root.children.first
        doc_sig  = Diffaroo::Signature.new(doc.root)
        node_sig = Diffaroo::Signature.new(node)
        doc_sig.weight(node).should == node_sig.weight
      end
    end

    context "passed an entity reference Node" do
      it "treats it like a leaf text node" do
        doc = Nokogiri::XML %q(<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"><html><span>&nbsp;</span></html>)
        node = doc.at_css("span").children.first
        doc_sig  = Diffaroo::Signature.new(doc.root)
        node_sig = Diffaroo::Signature.new(node)
        doc_sig.weight(node).should == node_sig.weight
      end
    end

    context "passed an invalid Node" do
      it "raises an error" do
        doc  = xml { root { a1("foo" => "bar") } }
        attr = doc.at_css("a1").attributes.first.last
        proc { Diffaroo::Signature.new.weight(attr) }.should raise_error(ArgumentError, /weight expects an element/) 
      end
    end

    it "weighs each node only once" do
      doc  = xml { root { a1 { b1 { c1 "hello" } } } }
      node = doc.at_css "c1"
      mock.proxy.instance_of(Diffaroo::Signature).weight(anything).times(5)
      Diffaroo::Signature.new.weight(doc.root)
    end

    it "caches weights" do
      doc  = xml { root { a1 { b1 { c1 "hello" } } } }
      node = doc.at_css "c1"
      mock.proxy.instance_of(Diffaroo::Signature).weight(anything).times(6)
      sig = Diffaroo::Signature.new
      sig.weight(doc.root)
      sig.weight(doc.root)
    end

    it "weighs empty nodes with no children as 1" do
      doc = xml { root { a1 } }
      sig = Diffaroo::Signature.new(doc.root)
      sig.weight(doc.at_css("a1")).should == 1
    end

    it "weighs nodes with children as 1 + sum(weight(children))" do
      doc = xml { root {
          a1 { b1 ; b2 }
          a2 { b1 ; b2 ; b3 ; b4 }
        } }
      sig = Diffaroo::Signature.new(doc.root)
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
        sig = Diffaroo::Signature.new(doc.root)
        sig.weight(doc.at_css("a1")).should be_close(2, 0.0005)
        sig.weight(doc.at_css("a2")).should be_close(2 + Math.log(500), 0.0005)
        sig.weight(doc.at_css("a3")).should be_close(2 + Math.log(50_000), 0.0005)
      end
    end
  end

  describe "#monogram" do
    context "passed no argument" do
      it "returns the subtree root's signature" do
        doc = xml { root { a1(:foo => :bar) } }
        sig = Diffaroo::Signature.new(doc.root)
        sig.monogram.should == sig.monogram(doc.root)
      end
    end

    context "passed a node" do
      it "returns the node's signature" do
        doc      = xml { root { a1(:foo => :bar) } }
        node     = doc.at_css("a1")
        doc_sig  = Diffaroo::Signature.new(doc.root)
        node_sig = Diffaroo::Signature.new(node)
        doc_sig.monogram(node).should == node_sig.monogram
      end
    end

    context "passed a non-Node" do
      it "raises an error" do
        proc { Diffaroo::Signature.new.monogram(42) }.should raise_error(ArgumentError, /signature expects a Node/)
      end
    end

    context "text nodes" do
      it "returns the signature as the monogram" do
        doc = xml { root { text "hello" } }
        node = doc.root.children.first
        sig = Diffaroo::Signature.new(doc.root)
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
        sig = Diffaroo::Signature.new(doc.root)
        sig.monogram(nodes[0]).should == sig.monogram(nodes[1])
        sig.monogram(nodes[1]).should == sig.monogram(nodes[2])
      end

      it "is inequal for nodes with different attributes" do
        doc = xml { root {
            a1(:foo => :bar)
            a1(:foo => :bar, :bazz => :quux)
          } }
        nodes = doc.css("a1")
        sig = Diffaroo::Signature.new(doc.root)
        sig.monogram(nodes[0]).should_not == sig.monogram(nodes[1])
      end
    end
  end
end
