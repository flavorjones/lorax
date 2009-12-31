require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Diffaroo::NokogiriHelper do
  describe "#uniquely_named_children_of" do
    it "returns an unordered array of the children in the trivial case of no repeats" do
      doc = xml { root { a1 ; a2 ; a3 } }
      Diffaroo::NokogiriHelper.uniquely_named_children_of(doc.root).should =~ doc.root.children.to_a
    end

    it "does not return nodes who are not uniquely named" do
      doc = xml { root { a1 ; a2 ; a3 ; a2 "hello" ; a3(:foo => :bar) } }
      Diffaroo::NokogiriHelper.uniquely_named_children_of(doc.root).should =~ [doc.at_css("a1")]
    end

    it "does not return nodes who appear more than twice" do
      doc = xml { root { a1 ; a2 ; a2 "hello" ; a2(:foo => :bar) } }
      Diffaroo::NokogiriHelper.uniquely_named_children_of(doc.root).should =~ [doc.at_css("a1")]
    end
  end
end
