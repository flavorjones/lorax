require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Diffaroo::Match do
  describe "#new" do
    it "takes two nodes and an integer as arguments" do
      doc1 = xml { root }
      doc2 = xml { root }
      proc { Diffaroo::Match.new(doc1.root, doc2.root) }.should_not raise_error
    end
  end

  describe "#pair" do
    it "returns the two nodes in an array" do
      doc1 = xml { root }
      doc2 = xml { root }
      Diffaroo::Match.new(doc1.root, doc2.root).pair.should == [doc1.root, doc2.root]
    end
  end

  describe "#other" do
    context "the node is in the pair" do
      it "returns the other node" do
        match = Diffaroo::Match.new :a, :b
        match.other(:a).should == :b
        match.other(:b).should == :a
      end
    end

    context "the node is not in the pair" do
      it "returns nil" do
        Diffaroo::Match.new(:a, :b).other(:c).should be_nil
      end
    end
  end
end
