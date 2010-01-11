require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Diffaroo::DeltaSetGenerator do
  describe "#generate_delta_set" do
    context "InsertDeltas" do
      it "should be generated for an atomic node without a match" do
        doc1 = xml { root1 }
        doc2 = xml { root2 }
        match_set = Diffaroo::MatchSet.new doc1, doc2
        delta_set = Diffaroo::DeltaSetGenerator.generate_delta_set(match_set)
        delta_set.deltas.select { |d| d.is_a?(Diffaroo::InsertDelta) }.length.should == 1
      end

      it "should be generated for a subtree without a match" do
        doc1 = xml { root1 }
        doc2 = xml { root2 { a1 ; a2 "hello" } }
        match_set = Diffaroo::MatchSet.new doc1, doc2
        delta_set = Diffaroo::DeltaSetGenerator.generate_delta_set(match_set)
        delta_set.deltas.select { |d| d.is_a?(Diffaroo::InsertDelta) }.length.should == 1
      end

      it "should not be generated for children of a perfect match" do
        doc1 = xml { root { a1 { b1 "hello" }      } }
        doc2 = xml { root { a1 { b1 "hello" } ; a2 } }
        match_set = Diffaroo::MatchSet.new doc1, doc2
        match_set.add Diffaroo::Match.new(doc1.at_css("root"), doc2.at_css("root"))
        match_set.add Diffaroo::Match.new(doc1.at_css("a1"),   doc2.at_css("a1"), :perfect => true)
        delta_set = Diffaroo::DeltaSetGenerator.generate_delta_set(match_set)
        delta_set.deltas.select { |d| d.is_a?(Diffaroo::InsertDelta) }.length.should == 1 # a2
      end

      it "should be generated for siblings without a match" do
        doc1 = xml { root {
            a1 "hello"
            a3 "goodbye"
            a5 "again"
          } }
        doc2 = xml { root {
            a1 "hello"
            a2 "middleman"
            a3 "goodbye"
            a4 "good boy"
            a5 "again"
          } }
        match_set = Diffaroo::MatchSet.new doc1, doc2
        match_set.add Diffaroo::Match.new(doc1.at_css("a1"), doc2.at_css("a1"), :perfect => true)
        match_set.add Diffaroo::Match.new(doc1.at_css("a3"), doc2.at_css("a3"), :perfect => true)
        match_set.add Diffaroo::Match.new(doc1.at_css("a5"), doc2.at_css("a5"), :perfect => true)
        match_set.add Diffaroo::Match.new(doc1.at_css("root"), doc2.at_css("root"))
        delta_set = Diffaroo::DeltaSetGenerator.generate_delta_set(match_set)
        delta_set.deltas.select { |d| d.is_a?(Diffaroo::InsertDelta) }.length.should == 2
      end
    end

    context "ModifyDeltas" do
      it "should be generated for nodes that are imperfectly matched" do
        doc1 = xml { root(:foo => :bar) }
        doc2 = xml { root(:foo => :quux) }
        match_set = Diffaroo::MatchSet.new doc1, doc2
        match_set.add Diffaroo::Match.new doc1.at_css("root"), doc2.at_css("root")
        delta_set = Diffaroo::DeltaSetGenerator.generate_delta_set(match_set)
        delta_set.deltas.select { |d| d.is_a?(Diffaroo::ModifyDelta) }.length.should == 1
      end

      context "imperfect self-same match with children" do
        it "should handle children as expected" do
          doc1 = xml { root {
              a1
              a2
              a4(:foo => :bar)
            } }
          doc2 = xml { root {
              a2
              a3
              a4(:foo => :quux)
            } }
          match_set = Diffaroo::MatchSet.new doc1, doc2
          match_set.add Diffaroo::Match.new doc1.root, doc2.root
          match_set.add Diffaroo::Match.new doc1.at_css("a2"), doc2.at_css("a2"), :perfect => true
          match_set.add Diffaroo::Match.new doc1.at_css("a4"), doc2.at_css("a4")
          delta_set = Diffaroo::DeltaSetGenerator.generate_delta_set(match_set)
          delta_set.deltas.select { |d| d.is_a?(Diffaroo::InsertDelta) }.length.should == 1 # a3
          delta_set.deltas.select { |d| d.is_a?(Diffaroo::ModifyDelta) }.length.should == 1 # a4
          delta_set.deltas.select { |d| d.is_a?(Diffaroo::DeleteDelta) }.length.should == 1 # a1
        end
      end

      it "should not be generated for nodes that are imperfectly matched but are self-same" do
        doc1 = xml { root(:foo => :bar) { a1 } }
        doc2 = xml { root(:foo => :bar) { a2 } }
        match_set = Diffaroo::MatchSet.new doc1, doc2
        match_set.add Diffaroo::Match.new doc1.at_css("root"), doc2.at_css("root")
        delta_set = Diffaroo::DeltaSetGenerator.generate_delta_set(match_set)
        delta_set.deltas.select { |d| d.is_a?(Diffaroo::ModifyDelta) }.length.should == 0
      end

      it "should not be generated for nodes that are perfectly matched" do
        doc1 = xml { root }
        doc2 = xml { root }
        match_set = Diffaroo::MatchSet.new doc1, doc2
        match_set.add Diffaroo::Match.new doc1.at_css("root"), doc2.at_css("root"), :perfect => true
        delta_set = Diffaroo::DeltaSetGenerator.generate_delta_set(match_set)
        delta_set.deltas.select { |d| d.is_a?(Diffaroo::ModifyDelta) }.length.should == 0
      end
    end

    context "DeleteDeltas" do
      it "should be generated for an atomic node without a match" do
        doc1 = xml { root1 }
        doc2 = xml { root2 }
        match_set = Diffaroo::MatchSet.new doc1, doc2
        delta_set = Diffaroo::DeltaSetGenerator.generate_delta_set(match_set)
        delta_set.deltas.select { |d| d.is_a?(Diffaroo::DeleteDelta) }.length.should == 1
      end

      it "should be generated for a subtree without a match" do
        doc1 = xml { root1 { a1 ; a2 "hello" } }
        doc2 = xml { root2 }
        match_set = Diffaroo::MatchSet.new doc1, doc2
        delta_set = Diffaroo::DeltaSetGenerator.generate_delta_set(match_set)
        delta_set.deltas.select { |d| d.is_a?(Diffaroo::DeleteDelta) }.length.should == 1
      end

      it "should not be generated for children of a deleted node" do
        doc1 = xml { root { a1 { b1 "hello" } ; a2 } }
        doc2 = xml { root {                     a2 } }
        match_set = Diffaroo::MatchSet.new doc1, doc2
        match_set.add Diffaroo::Match.new(doc1.at_css("root"), doc2.at_css("root"))
        match_set.add Diffaroo::Match.new(doc1.at_css("a2"),   doc2.at_css("a2"), :perfect => true)
        delta_set = Diffaroo::DeltaSetGenerator.generate_delta_set(match_set)
        delta_set.deltas.select { |d| d.is_a?(Diffaroo::DeleteDelta) }.length.should == 1 # a1
      end

      it "should be generated for siblings without a match" do
        doc1 = xml { root {
            a1 "hello"
            a2 "middleman"
            a3 "goodbye"
            a4 "good boy"
            a5 "again"
          } }
        doc2 = xml { root {
            a1 "hello"
            a3 "goodbye"
            a5 "again"
          } }
        match_set = Diffaroo::MatchSet.new doc1, doc2
        match_set.add Diffaroo::Match.new(doc1.at_css("a1"), doc2.at_css("a1"), :perfect => true)
        match_set.add Diffaroo::Match.new(doc1.at_css("a3"), doc2.at_css("a3"), :perfect => true)
        match_set.add Diffaroo::Match.new(doc1.at_css("a5"), doc2.at_css("a5"), :perfect => true)
        match_set.add Diffaroo::Match.new(doc1.at_css("root"), doc2.at_css("root"))
        delta_set = Diffaroo::DeltaSetGenerator.generate_delta_set(match_set)
        delta_set.deltas.select { |d| d.is_a?(Diffaroo::DeleteDelta) }.length.should == 2
      end
    end
  end
end
