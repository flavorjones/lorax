require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Lorax::DeltaSet do
  describe "#add / #deltas" do
    it "appends to and returns an ordered list of deltas" do
      delta_set = Lorax::DeltaSet.new
      delta_set.add :foo
      delta_set.add :bar
      delta_set.deltas.should == [:foo, :bar]
    end
  end

  describe "#apply" do
    it "calls apply! on a duplicate document" do
      delta_set = Lorax::DeltaSet.new
      document  = Nokogiri::XML::Document.new
      mock(document).dup { :foo }
      mock(delta_set).apply!(:foo)
      delta_set.apply document
    end
  end

  describe "#apply!" do
    it "invokes apply! on each delta in order" do
      doc = xml { root }
      delta_set = Lorax::DeltaSet.new
      delta1 = Lorax::InsertDelta.new(:foo, :bar, :quux)
      delta2 = Lorax::InsertDelta.new(:foo, :bar, :quux)
      delta_set.add delta1
      delta_set.add delta2

      order_of_invocation = []
      mock(delta1).apply!(doc) { order_of_invocation << :delta1 }
      mock(delta2).apply!(doc) { order_of_invocation << :delta2 }
      delta_set.apply!(doc)

      order_of_invocation.should == [:delta1, :delta2]
    end
  end
end
