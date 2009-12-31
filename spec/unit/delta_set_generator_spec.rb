require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Diffaroo::DeltaSetGenerator do
  describe "#generate_delta_set" do
    it "should generate an InsertDelta for an atomic node" do
      doc1 = xml { root1 }
      doc2 = xml { root2 }
      match_set = Diffaroo::MatchSet.new doc1, doc2
      delta_set = Diffaroo::DeltaSetGenerator.generate_delta_set(match_set)
      delta_set.deltas.length.should == 1
      delta_set.deltas.first.should be_instance_of(Diffaroo::InsertDelta)
    end

    it "should generate an InsertDelta for a subtree" do
      doc1 = xml { root1 }
      doc2 = xml { root2 { a1 ; a2 "hello" } }
      match_set = Diffaroo::MatchSet.new doc1, doc2
      delta_set = Diffaroo::DeltaSetGenerator.generate_delta_set(match_set)
      delta_set.deltas.length.should == 1
      delta_set.deltas.first.should be_instance_of(Diffaroo::InsertDelta)
    end
  end
end
