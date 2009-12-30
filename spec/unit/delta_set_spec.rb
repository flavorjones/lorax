require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Diffaroo::DeltaSet do
  describe ".new" do
    context "is passed a MatchSet" do
      before { @match_set = Diffaroo::MatchSet.new(xml { root }, xml { root }) }

      it "does not raise an error" do
        proc { Diffaroo::DeltaSet.new @match_set }.should_not raise_error
      end

      it "calls generate_deltas" do
        mock.proxy.instance_of(Diffaroo::DeltaSet).generate_deltas
        Diffaroo::DeltaSet.new @match_set
      end
    end

    context "is passed a nil (hopefully for testing purposes" do
      it "does not raise an error" do
        proc { Diffaroo::DeltaSet.new nil }.should_not raise_error
      end

      it "does not call generate_deltas" do
        mock.proxy.instance_of(Diffaroo::DeltaSet).generate_deltas.never
        proc { Diffaroo::DeltaSet.new nil }.should_not raise_error
      end
    end

    context "is passed non-nil non-MatchSet" do
      it "raises an error" do
        proc { Diffaroo::DeltaSet.new 1 }.should raise_error(ArgumentError)
      end
    end
  end

  describe "#match_set" do
    it "returns the match set passed to #new" do
      match_set = Diffaroo::MatchSet.new(xml { root }, xml { root })
      delta_set = Diffaroo::DeltaSet.new match_set
      delta_set.match_set.should == match_set
    end
  end

  describe "#add / #deltas" do
    it "appends to and returns an ordered list of deltas" do
      delta_set = Diffaroo::DeltaSet.new nil
      delta_set.add :foo
      delta_set.add :bar
      delta_set.deltas.should == [:foo, :bar]
    end
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
    it "invokes apply! on each delta in order" do
      doc = xml { root }
      delta_set = Diffaroo::DeltaSet.new nil
      delta1 = Diffaroo::InsertDelta.new(:foo, :bar)
      delta2 = Diffaroo::InsertDelta.new(:foo, :bar)
      delta_set.add delta1
      delta_set.add delta2

      order_of_invocation = []
      mock(delta1).apply!(doc) { order_of_invocation << :delta1 }
      mock(delta2).apply!(doc) { order_of_invocation << :delta2 }
      delta_set.apply!(doc)

      order_of_invocation.should == [:delta1, :delta2]
    end
  end

  describe "#generate_deltas" do
    it "needs a spec"
  end
end
