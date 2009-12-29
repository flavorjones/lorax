require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Diffaroo::InsertDelta do
  describe ".new" do
    it "needs a spec"
  end

  describe "#node" do
    it "needs a spec"
  end

  describe "#xpath" do
    it "needs a spec"
  end

  describe "#apply!" do
    context "with resolvable xpath" do
      it "should insert a copy of the node into the document" do
        doc1 = xml { root }
        doc2 = xml { root { a1 } }
        node = doc2.at_css("a1")
        delta = Diffaroo::InsertDelta.new node, node.parent.path

        delta.apply!(doc1)

        doc1.at_css("a1").should_not be_nil
        node.parent.should == doc2.root
      end
    end

    context "when unresolvable xpath" do
      it "should raise a Conflict exception" do
        doc1 = xml { root }
        doc2 = xml { root { a1 } }
        node = doc2.at_css("a1")
        delta = Diffaroo::InsertDelta.new node, "/foo/bar/quux"

        proc { delta.apply!(doc1) }.should raise_error(Diffaroo::Delta::NodeNotFoundError)
      end
    end
  end
end
