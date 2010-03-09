require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Lorax::Match do
  before do
    @doc1 = xml { root }
    @doc2 = xml { root }
  end

  describe "#new" do
    it "takes two nodes as arguments" do
      proc { Lorax::Match.new(@doc1.root, @doc2.root) }.should_not raise_error
    end

    it "takes optional options" do
      proc { Lorax::Match.new(@doc1.root, @doc2.root, {:perfect => true}) }.should_not raise_error
    end
  end

  describe "#perfect" do
    it "returns true if {:perfect => true} option was passed to #new" do
      Lorax::Match.new(@doc1.root, @doc2.root, {:perfect => true}).should be_perfect      
    end

    it "returns false if {:perfect => false} option was passed to #new" do
      Lorax::Match.new(@doc1.root, @doc2.root, {:perfect => false}).should_not be_perfect      
    end

    it "returns false if no :perfect option was passed to #new" do
      Lorax::Match.new(@doc1.root, @doc2.root).should_not be_perfect      
    end
  end

  describe "#pair" do
    it "returns the two nodes in an array" do
      Lorax::Match.new(@doc1.root, @doc2.root).pair.should == [@doc1.root, @doc2.root]
    end
  end

  describe "#other" do
    context "the node is in the pair" do
      it "returns the other node" do
        match = Lorax::Match.new :a, :b
        match.other(:a).should == :b
        match.other(:b).should == :a
      end
    end

    context "the node is not in the pair" do
      it "returns nil" do
        Lorax::Match.new(:a, :b).other(:c).should be_nil
      end
    end
  end
end
