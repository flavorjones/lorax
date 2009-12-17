require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Diffaroo::Signature do
  def assert_node_hash_equal(node1, node2)
    Diffaroo::Signature.new(node1).hash.should == Diffaroo::Signature.new(node2).hash
  end

  def assert_node_hash_not_equal(node1, node2)
    Diffaroo::Signature.new(node1).hash.should_not == Diffaroo::Signature.new(node2).hash
  end

  describe "API" do
    describe ".new" do
      it "accepts nil" do
        proc { Diffaroo::Signature.new }.should_not raise_error
      end

      it "does not call node_hash if param is nil" do
        mock.instance_of(Diffaroo::Signature).node_hash(42).never
      end

      it "calls node_hash if a param is non-nil" do
        mock.instance_of(Diffaroo::Signature).node_hash(42).once
        Diffaroo::Signature.new(42)
      end
    end

    describe "#node_hash" do
      it "raises an error if passed a non-Node" do
        proc { Diffaroo::Signature.new.node_hash(42) }.should raise_error(ArgumentError)
      end

      it "raises an error if passed a non-text, non-element Node" do
        doc = xml { root { a1("foo" => "bar") } }
        attr = doc.at_css("a1").attributes.first.last
        proc { Diffaroo::Signature.new.node_hash(attr) }.should raise_error(ArgumentError) 
      end

      it "hashes each node only once" do
        doc = xml { root { a1 { b1 { c1 "hello" } } } }
        node = doc.at_css "c1"
        mock.proxy.instance_of(Diffaroo::Signature).node_hash(anything).times(5)
        Diffaroo::Signature.new.node_hash(doc.root)
      end
    end

    it "has a node accessor" do
      doc = xml { root "hello" }
      sig = Diffaroo::Signature.new(doc.root)
      sig.node.should == doc.at_css("root")
    end

    it "has a node hash accessor" do
      doc = xml { root "hello" }
      sig = Diffaroo::Signature.new(doc.root)
      sig.hash.should == Diffaroo::Signature.new.node_hash(doc.at_css("root"))
    end

    it "has a hashes accessor" do
      doc      = xml { root { a1 "hello" } }
      node     = doc.at_css("a1")
      doc_sig  = Diffaroo::Signature.new(doc.root)
      node_sig = Diffaroo::Signature.new(node)
      doc_sig.hashes[node].should == node_sig.hash
    end
  end

  describe "#node_hash" do
    context "identical text nodes" do
      it "hashes equally" do
        doc = xml { root {
            span "hello"
            span "hello"
          } }
        assert_node_hash_equal(*doc.css("span").collect { |n| n.children.first })
      end
    end

    context "different text nodes" do
      it "hashes differently" do
        doc = xml { root {
            span "hello"
            span "goodbye"
          } }
        assert_node_hash_not_equal(*doc.css("span").collect { |n| n.children.first })
      end
    end

    context "elements with same name (with no attributes and no content)" do
      it "hashes equally" do
        doc = xml { root { a1 ; a1 } }
        assert_node_hash_equal(*doc.css("a1"))
      end
    end

    context "elements with different names" do
      it "hashes differently" do
        doc = xml { root { a1 ; a2 } }
        assert_node_hash_not_equal doc.at_css("a1"), doc.at_css("a2")
      end
    end

    context "same elements in different docs" do
      it "hashes equally" do
        doc1 = xml { root { a1 } }
        doc2 = xml { root { a1 } }
        assert_node_hash_equal doc1.at_css("a1"), doc2.at_css("a1")
      end
    end

    context "elements with same name and content (with no attributes)" do
      context "and content is the same" do
        it "hashes equally" do
          doc = xml { root {
              a1 "hello"
              a1 "hello"
            } }
          assert_node_hash_equal(*doc.css("a1"))
        end
      end

      context "and content is not the same" do
        it "hashes equally" do
          doc = xml { root {
              a1 "hello"
              a1 "goodbye"
            } }
          assert_node_hash_not_equal(*doc.css("a1"))
        end
      end
    end

    context "elements with same name and children (with no attributes)" do
      context "and children are in the same order" do
        it "hashes equally" do
          doc = xml { root {
              a1 { b1 ; b2 }
              a1 { b1 ; b2 }
            } }
          assert_node_hash_equal(*doc.css("a1"))
        end
      end

      context "and children are not in the same order" do
        it "hashes differently" do
          doc = xml { root {
              a1 { b1 ; b2 }
              a1 { b2 ; b1 }
            } }
          assert_node_hash_not_equal(*doc.css("a1"))
        end
      end
    end

    context "elements with same name and same attributes (with no content)" do
      it "hashes equally" do
        doc = xml { root {
            a1("foo" => "bar", "bazz" => "quux")
            a1("foo" => "bar", "bazz" => "quux")
          } }
        assert_node_hash_equal(*doc.css("a1"))
      end
    end

    context "elements with same name and different attributes (with no content)" do
      it "hashes differently" do
        doc = xml { root {
            a1("foo" => "bar", "bazz" => "quux")
            a1("foo" => "123", "bazz" => "456")
          } }
        assert_node_hash_not_equal(*doc.css("a1"))
      end
    end

    context "attributes reverse-engineered to be similar" do
      it "hashes differently" do
        doc = xml { root {
            a1("foo" => "bar#{Diffaroo::Signature::SEP}quux")
            a1("foo#{Diffaroo::Signature::SEP}bar" => "quux")
          } }
        assert_node_hash_not_equal(*doc.css("a1"))
      end
    end

    context "HTML" do
      it "write some case-insensitive HTML tests"
    end
  end
end
