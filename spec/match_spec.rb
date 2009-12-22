require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Diffaroo::Match do
  describe "#new" do
    it "takes two nodes and an integer as arguments" do
      doc1 = xml { root }
      doc2 = xml { root }
      proc { Diffaroo::Match.new(doc1.root, doc2.root, 1) }.should_not raise_error
    end
  end

  describe "#pair" do
    it "returns the two nodes in an array" do
      doc1 = xml { root }
      doc2 = xml { root }
      Diffaroo::Match.new(doc1.root, doc2.root, 1).pair.should == [doc1.root, doc2.root]
    end
  end

  describe "#parent_offset" do
    it "returns the integer passed to the initializer" do
      doc1 = xml { root }
      doc2 = xml { root }
      Diffaroo::Match.new(doc1.root, doc2.root, 42).parent_offset.should == 42
    end
  end
end
