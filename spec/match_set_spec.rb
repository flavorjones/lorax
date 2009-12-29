require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

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

  describe "#matches" do
    it "returns the array of Match objects" do
      doc1 = xml { root1 { a1 ; a2 } }
      doc2 = xml { root2 { a1 ; a2 } }
      match_set = Diffaroo::MatchSet.new(doc1, doc2)
      match_set.matches.should be_instance_of(Array)
      match = Diffaroo::Match.new(doc1.at_css("a1"), doc2.at_css("a1"), 0)
      match_set.add match
      match_set.matches.first.should == match
    end
  end

  describe "#pairs" do
    it "returns the collected node pairs from the matches" do
      doc1 = xml { root1 { a1 ; a2 } }
      doc2 = xml { root2 { a1 ; a2 } }
      match_set = Diffaroo::MatchSet.new(doc1, doc2)
      match_set.add Diffaroo::Match.new(doc1.at_css("a1"), doc2.at_css("a1"), 0)
      match_set.add Diffaroo::Match.new(doc1.at_css("a2"), doc2.at_css("a2"), 0)
      match_set.pairs.should == [ [doc1.at_css("a1"), doc2.at_css("a1")],
                                  [doc1.at_css("a2"), doc2.at_css("a2")] ]
    end
  end

  describe "#matched?" do
    before do
      @doc1 = xml { root1 { a1 } }
      @doc2 = xml { root2 { a1 } }
      @match_set = Diffaroo::MatchSet.new(@doc1, @doc2)
    end

    it "returns true if the node has been matched" do
      @match_set.add Diffaroo::Match.new(@doc1.at_css("a1"), @doc2.at_css("a1"), 0)
      @match_set.matched?(@doc1.at_css("a1")).should be_true
      @match_set.matched?(@doc2.at_css("a1")).should be_true
    end

    it "returns false if the node has not been matched" do
      @match_set.matched?(@doc1.at_css("a1")).should be_false
      @match_set.matched?(@doc2.at_css("a1")).should be_false
    end
  end

  describe "#match" do
    before do
      @doc1 = xml { root1 { a1 } }
      @doc2 = xml { root2 { a1 } }
      @match_set = Diffaroo::MatchSet.new(@doc1, @doc2)
    end

    context "when there is a match" do
      before { @match_set.add Diffaroo::Match.new(@doc1.at_css("a1"), @doc2.at_css("a1"), 0) }

      it "returns the match" do
        @match_set.matched?(@doc1.at_css("a1")).should be_true
        @match_set.matched?(@doc2.at_css("a1")).should be_true
      end
    end

    context "when there is no match" do
      it "returns nil" do
        @match_set.matched?(@doc1.at_css("a1")).should be_false
        @match_set.matched?(@doc2.at_css("a1")).should be_false
      end
    end
  end

  describe "#complement" do
    context "passed a node that has not been matched" do
      it "returns nil" do
        doc1 = xml { root }
        doc2 = doc1.dup
        match_set = Diffaroo::MatchSet.new(doc1, doc2)
        match_set.complement(doc1.root).should be_nil
      end
    end

    context "given a matched node from document1" do
      it "returns the matching node from document2" do
        doc1 = xml { root }
        doc2 = doc1.dup
        match_set = Diffaroo::MatchSet.new(doc1, doc2)
        match_set.add Diffaroo::Match.new(doc1.root, doc2.root, 0)
        match_set.complement(doc1.root).should == doc2.root
      end
    end

    context "given a matched node from document2" do
      it "returns the matching node from document1" do
        doc1 = xml { root }
        doc2 = doc1.dup
        match_set = Diffaroo::MatchSet.new(doc1, doc2)
        match_set.add Diffaroo::Match.new(doc1.root, doc2.root, 0)
        match_set.complement(doc2.root).should == doc1.root
      end
    end
  end

  describe "#add" do
    before do
      doc1 = xml { root1 { a1 } }
      doc2 = xml { root2 { a1 } }
      @match_set = Diffaroo::MatchSet.new(doc1, doc2)
      @match = Diffaroo::Match.new(:a, :b, 0)
    end

    it "adds the passed match to the list of matches" do
      @match_set.add @match
      @match_set.matches.should include(@match)
    end

    it "returns #matched? as true for those nodes" do
      @match_set.matched?(:a).should be_false
      @match_set.matched?(:b).should be_false

      @match_set.add @match
      @match_set.matched?(:a).should be_true
      @match_set.matched?(:b).should be_true
    end
  end
end
