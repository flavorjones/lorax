require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Diffaroo do
  context "inserted nodes" do
    it "is able to recreate doc2 based on doc1 and the DeltaSet" do
      doc1 = xml { root {
          a1 "hello"
          a2
        } }
      doc2 = xml { root {
          a1 "hello"
          a2 {
            b1 "subnode"
          }
          a3 "goodbye"
        } }

      delta_set = Diffaroo.diff(doc1, doc2)
      new_doc = delta_set.apply(doc1)

      Diffaroo::Signature.new(new_doc.root).signature.should == Diffaroo::Signature.new(doc2.root).signature
    end
  end
end
