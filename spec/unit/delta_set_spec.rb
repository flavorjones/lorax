require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Diffaroo::DeltaSet do
  describe ".new" do
    it "takes a match set" do
      match_set = Diffaroo::MatchSet.new(xml { root }, xml { root })
      proc { Diffaroo::DeltaSet.new match_set }.should_not raise_error
    end

    it "raises an error if passed something that is not a match set" do
      proc { Diffaroo::DeltaSet.new 1 }.should raise_error(ArgumentError)
    end

    it "generates insert deltas"
  end

  describe "#add" do
    it "needs a spec"
  end

  describe "#deltas" do
    it "needs a spec"
  end

  describe "#apply" do
    it "calls apply! on a duplicate document" do
      match_set = Diffaroo::MatchSet.new(xml { root }, xml { root })
      delta_set = Diffaroo::DeltaSet.new(match_set)
      document  = Nokogiri::XML::Document.new
      mock(document).dup { :foo }
      mock(delta_set).apply!(:foo)
      delta_set.apply document
    end
  end

  describe "#apply!" do
    context "when there are insert deltas" do
      it "does something"
    end
  end

  describe "#match_set" do
    it "returns the match set passed to #new" do
      match_set = Diffaroo::MatchSet.new(xml { root }, xml { root })
      delta_set = Diffaroo::DeltaSet.new match_set
      delta_set.match_set.should == match_set
    end
  end
end
