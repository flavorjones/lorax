require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Diffaroo::InsertDelta do
  describe ".new" do
    it "takes three arguments" do
      proc { Diffaroo::InsertDelta.new(:foo, :bar)              }.should     raise_error(ArgumentError)
      proc { Diffaroo::InsertDelta.new(:foo, :bar, :quux)       }.should_not raise_error(ArgumentError)
      proc { Diffaroo::InsertDelta.new(:foo, :bar, :quux, :fuzz)}.should     raise_error(ArgumentError)
    end
  end

  describe "#node" do
    it "returns the first argument to #new" do
      Diffaroo::InsertDelta.new(:foo, :bar, :quux).node.should == :foo
    end
  end

  describe "#xpath" do
    it "returns the second argument to #new" do
      Diffaroo::InsertDelta.new(:foo, :bar, :quux).xpath.should == :bar
    end
  end

  describe "#position" do
    it "returns the third argument to #new" do
      Diffaroo::InsertDelta.new(:foo, :bar, :quux).position.should == :quux
    end
  end

  describe "#apply!" do
    context "for an atomic node delta" do
      it "should insert a copy into the document" do
        doc1 = xml { root }
        doc2 = xml { root { a1 } }
        node = doc2.at_css("a1")
        delta = Diffaroo::InsertDelta.new node, node.parent.path, 0

        delta.apply!(doc1)

        doc1.at_css("a1").should_not be_nil
        node.parent.should == doc2.root
      end
    end

    context "for a subtree node delta" do
      it "should insert a copy into the document" do
        doc1 = xml { root }
        doc2 = xml { root { a1 { b1 ; b2 "hello" } } }
        node = doc2.at_css("a1")
        delta = Diffaroo::InsertDelta.new node, node.parent.path, 0

        delta.apply!(doc1)

        doc1.at_css("a1").should_not be_nil
        node.parent.should == doc2.root
      end
    end

    context "sibling node insertions" do
      it "should insert at the front" do
        doc1 = xml { root { a2 } }
        doc2 = xml { root { a1 ; a2 } }
        node = doc2.at_css("a1")
        delta = Diffaroo::InsertDelta.new node, node.parent.path, 0

        delta.apply! doc1

        doc1.root.children.map {|child| child.name}.should == %w[a1 a2]
      end

      it "should insert at the middle" do
        doc1 = xml { root { a1 ; a3 } }
        doc2 = xml { root { a1 ; a2 ; a3 } }
        node = doc2.at_css("a2")
        delta = Diffaroo::InsertDelta.new node, node.parent.path, 1

        delta.apply! doc1

        doc1.root.children.map {|child| child.name}.should == %w[a1 a2 a3]
      end

      it "should insert at the end" do
        doc1 = xml { root { a1 } }
        doc2 = xml { root { a1 ; a2 } }
        node = doc2.at_css("a2")
        delta = Diffaroo::InsertDelta.new node, node.parent.path, 1

        delta.apply! doc1

        doc1.root.children.map {|child| child.name}.should == %w[a1 a2]
      end
    end

    context "delta with unresolvable xpath" do
      it "should raise a Conflict exception" do
        doc1 = xml { root }
        doc2 = xml { root { a1 } }
        node = doc2.at_css("a1")
        delta = Diffaroo::InsertDelta.new node, "/foo/bar/quux", 0

        proc { delta.apply!(doc1) }.should raise_error(Diffaroo::Delta::NodeNotFoundError)
      end
    end
  end
end
