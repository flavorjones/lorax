require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Diffaroo do
  def round_trip_should_succeed(doc1, doc2)
    delta_set = Diffaroo.diff(doc1, doc2)
    new_doc   = delta_set.apply(doc1)

    unless Diffaroo::Signature.new(new_doc.root).signature == Diffaroo::Signature.new(doc2.root).signature
      errmsg = []
      errmsg << "Documents are not identical after a round-trip diff and patch:"
      errmsg << doc1.root.to_xml
      errmsg << "-----"
      errmsg << doc2.root.to_xml
      errmsg << "=> patch: #{delta_set.deltas.inspect}"
      errmsg << new_doc.root.to_xml
      fail errmsg.join("\n")
    end
  end

  context "inserted nodes" do
    it "handles appends to matching siblings" do
      doc1 = xml { root {
          a1 "hello"
        } }
      doc2 = xml { root {
          a1 "hello"
          a2 "goodbye"
        } }
      round_trip_should_succeed doc1, doc2
    end

    it "inserts into matching siblings" do
      doc1 = xml { root {
          a1 "hello"
          a3 "goodbye"
        } }
      doc2 = xml { root {
          a1 "hello"
          a2
          a3 "goodbye"
        } }
      round_trip_should_succeed doc1, doc2
    end

    it "inserts under an existing sibling node" do
      doc1 = xml { root {
          a1 "hello"
          a2
        } }
      doc2 = xml { root {
          a1 "hello"
          a2 { b1 "subnode" }
        } }
      round_trip_should_succeed doc1, doc2
    end
  end

  context "deleted nodes" do
    it "handles deleting nodes" do
      doc1 = xml { root {
          a1 "hello"
          a2 "goodbye"
          a3 "natch"
        } }
      doc2 = xml { root {
          a1 "hello"
          a3 "natch"
        } }
      round_trip_should_succeed doc1, doc2
    end
  end

  context "modified nodes" do
    it "handles modifying nodes" do
      doc1 = xml { root {
          a1 "hello"
          a2 "goodbye"
          a3 "natch"
        } }
      doc2 = xml { root {
          a1 "hello"
          a2 "good buy"
          a3 "natch"
        } }
      round_trip_should_succeed doc1, doc2
    end
  end

  context "mixed operations" do
    it "handles mixed deletions and modifications" do
      doc1 = xml { root {
          a1 "hello"
          a2 "goodbye"
          a3 "natch"
          a4 "jimmy"
        } }
      doc2 = xml { root {
          a1 "hello"
          a3 "not"
          a4 "jimmy"
        } }
      round_trip_should_succeed doc1, doc2
    end
  end

  context "with whitespace interleaved" do
    it "handles whitespace nodes" do
      doc1 = xml { root {
          a1
          text "\n\n"
          a2
          text "\n\n"
          a3
        } }
      doc2 = xml { root {
          a1
          text "\n\n"
          a10
          text "\n\n"
          a2
          text "\n\n"
          a3
        } }
      round_trip_should_succeed doc1, doc2
    end
  end

end
