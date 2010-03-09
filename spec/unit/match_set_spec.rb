require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Lorax::MatchSet do
  describe "#new" do
    context "normal usage" do
      it "takes two arguments" do
        proc { Lorax::MatchSet.new(xml{root})            }.should     raise_error(ArgumentError)
        proc { Lorax::MatchSet.new(xml{root}, xml{root}) }.should_not raise_error(ArgumentError)
      end

      it "builds a Signature for each document root" do
        doc1 = xml { root1 }
        doc2 = xml { root2 }
        mock.proxy(Lorax::Signature).new(doc1.root)
        mock.proxy(Lorax::Signature).new(doc2.root)
        Lorax::MatchSet.new(doc1, doc2)
      end
    end

    context "with dependency injection" do
      it "takes an optional third argument for dependency injection" do
        proc { Lorax::MatchSet.new(xml{root}, xml{root}, {:foo => :bar}) }.should_not raise_error(ArgumentError)
      end

      it "will use the value of ':match_set_signature1' for @signature1" do
        match_set = Lorax::MatchSet.new(xml{root}, xml{root}, {:match_set_signature1 => :foo})
        match_set.signature1.should == :foo
      end

      it "will use the value of ':match_set_signature2' for @signature2" do
        match_set = Lorax::MatchSet.new(xml{root}, xml{root}, {:match_set_signature2 => :foo})
        match_set.signature2.should == :foo
      end
    end
  end

  describe "#signature1" do
    it "returns the Signature of the first document" do
      doc1 = xml { root1 }
      doc2 = xml { root2 }
      match_set = Lorax::MatchSet.new(doc1, doc2)
      match_set.signature1.should_not be_nil
      match_set.signature1.root.should == doc1.root
    end
  end

  describe "#signature2" do
    it "returns the Signature of the second document" do
      doc1 = xml { root1 }
      doc2 = xml { root2 }
      match_set = Lorax::MatchSet.new(doc1, doc2)
      match_set.signature2.should_not be_nil
      match_set.signature2.root.should == doc2.root
    end
  end

  describe "#match and #add" do
    before do
      @doc1 = xml { root1 { a1 } }
      @doc2 = xml { root2 { a1 } }
      @match_set = Lorax::MatchSet.new(@doc1, @doc2)
    end

    context "when there is a match for the node" do
      before do
        @match = Lorax::Match.new(@doc1.at_css("a1"), @doc2.at_css("a1"))
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

  describe "#to_delta_set" do
    it "invokes DeltaSetGenerator.generate_delta_set on itself" do
      doc1 = xml { root1 }
      doc2 = xml { root2 }
      match_set = Lorax::MatchSet.new(doc1, doc2)
      mock(Lorax::DeltaSetGenerator).generate_delta_set(match_set)
      match_set.to_delta_set
    end
  end
end
