require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Diffaroo::MatchSet do
  describe "#new" do
    it "builds a Signature for each document root" do
      doc1 = xml { root1 }
      doc2 = xml { root2 }
      mock.proxy(Diffaroo::Signature).new(doc1.root)
      mock.proxy(Diffaroo::Signature).new(doc2.root)
      Diffaroo::MatchSet.new(doc1, doc2)
    end
  end

  describe "#signature1" do
    it "returns the Signature of the first document" do
      doc1 = xml { root1 }
      doc2 = xml { root2 }
      match_set = Diffaroo::MatchSet.new(doc1, doc2)
      match_set.signature1.should_not be_nil
      match_set.signature1.root.should == doc1.root
    end
  end

  describe "#signature2" do
    it "returns the Signature of the second document" do
      doc1 = xml { root1 }
      doc2 = xml { root2 }
      match_set = Diffaroo::MatchSet.new(doc1, doc2)
      match_set.signature2.should_not be_nil
      match_set.signature2.root.should == doc2.root
    end
  end

  describe "#match and #add" do
    before do
      @doc1 = xml { root1 { a1 } }
      @doc2 = xml { root2 { a1 } }
      @match_set = Diffaroo::MatchSet.new(@doc1, @doc2)
    end

    context "when there is a match for the node" do
      before do
        @match = Diffaroo::Match.new(@doc1.at_css("a1"), @doc2.at_css("a1"))
        @match_set.add @match
      end

      it "returns the match" do
        @match_set.match(@doc1.at_css("a1")).should == @match
        @match_set.match(@doc2.at_css("a1")).should == @match
      end
    end

    context "when there is no match" do
      it "returns nil" do
        @match_set.match(@doc1.at_css("a1")).should be_nil
        @match_set.match(@doc2.at_css("a1")).should be_nil
      end
    end
  end
end
