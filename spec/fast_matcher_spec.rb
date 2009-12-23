require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Diffaroo::FastMatcher do
  def new_fast_matched(doc1, doc2)
    matcher = Diffaroo::MatchSet.new(doc1, doc2)
    Diffaroo::FastMatcher.match(matcher)
    matcher
  end

  describe "basic node matching" do
    context "simple matches" do
      before do
        @doc1 = xml { root1 {
            a1("foo" => "bar") { text "snazzy" }
            b1 "123"
          } }
        @doc2 = xml { root2 {
            a1("foo" => "bar") { text "snazzy" }
            b2 "789"
          } }
      end

      it "matches identical nodes" do
        match_set = new_fast_matched(@doc1, @doc2)
        match_set.pairs.should include([@doc1.at_css("a1"), @doc2.at_css("a1")])
      end

      it "does not match different nodes" do
        match_set = new_fast_matched(@doc1, @doc2)
        match_set.pairs.flatten.should_not include(@doc1.at_css("b1"))
        match_set.pairs.flatten.should_not include(@doc2.at_css("b2"))
      end
    end

    context "nested matches" do
      before do
        @doc1 = xml { root { a1 "hello" } }
        @doc2 = xml { root { a1 "hello" } }
      end

      it "matches the largest identical subtree" do
        match_set = new_fast_matched(@doc1, @doc2)
        match_set.pairs.should include([@doc1.at_css("root"), @doc2.at_css("root")])
      end

      it "does not match small nodes within a larger matching subtree" do
        match_set = new_fast_matched(@doc1, @doc2)
        match_set.pairs.flatten.should_not include(@doc1.at_css("a1"))
        match_set.pairs.flatten.should_not include(@doc2.at_css("a1"))
      end
    end
  end

  describe "forced parent matching" do
    it "forces a match when parent names are the same but attributes are different" do
      doc1 = xml { root { a1(:foo => "bar")   { b1 } } }
      doc2 = xml { root { a1(:bazz => "quux") { b1 } } }
      match_set = new_fast_matched(doc1, doc2)
      match_set.pairs.should include([doc1.at_css("a1"), doc2.at_css("a1")])
    end

    it "forces a match when parent names and attributes are the same but siblings are different" do
      doc1 = xml { root { a1(:foo => "bar") { b1 "hello" ; b2 } } }
      doc2 = xml { root { a1(:foo => "bar") { b1 "hello" ; b3 } } }
      match_set = new_fast_matched(doc1, doc2)
      match_set.pairs.should include([doc1.at_css("a1"), doc2.at_css("a1")])
    end

    it "should not match any children" do
      large_doc1 = xml { root { a1 { b1 { c1 { d1 { e1 {
                    10.times { f1 "hello" }
                    f2
                  } } } } } } }
      large_doc2 = xml { root { a1 { b1 { c1 { d1 { e1 {
                    10.times { f1 "hello" }
                    f3
                  } } } } } } }
      large_match_set = new_fast_matched(large_doc1, large_doc2)
      large_match_set.matches.size.should == 1
    end

    it "large subtree matches force more parent matches than smaller subtree matches" do
      small_doc1 = xml { root { a1 { b1 { c1 { d1 { e1 {
                    f1 "hello"
                    f2
                  } } } } } } }
      small_doc2 = xml { root { a1 { b1 { c1 { d1 { e1 {
                    f1 "hello"
                    f3
                  } } } } } } }
      large_doc1 = xml { root { a1 { b1 { c1 { d1 { e1 {
                    f1 { 10.times { g1 "hello" } }
                    f2
                  } } } } } } }
      large_doc2 = xml { root { a1 { b1 { c1 { d1 { e1 {
                    f1 { 10.times { g1 "hello" } }
                    f3
                  } } } } } } }

      small_match_set = new_fast_matched(small_doc1, small_doc2)
      large_match_set = new_fast_matched(large_doc1, large_doc2)

      small_pairs = small_match_set.pairs
      small_pairs.should     include([small_doc1.at_css("e1"), small_doc2.at_css("e1")])
      small_pairs.should_not include([small_doc1.at_css("d1"), small_doc2.at_css("d1")])

      large_pairs = large_match_set.pairs
      large_pairs.should_not include([large_doc1.at_css("e1"), large_doc2.at_css("e1")])
      large_pairs.should_not include([large_doc1.at_css("d1"), large_doc2.at_css("d1")])
      large_pairs.should     include([large_doc1.at_css("c1"), large_doc2.at_css("c1")])
      large_pairs.should_not include([large_doc1.at_css("b1"), large_doc2.at_css("b1")])
    end
  end

  describe "choosing the best among multiple possible matches" do
    context "no match's parent is same-named" do
      it "we don't care which node we match, just pick one" do
        doc1 = xml { root {
            a1 { b1 }
          } }
        doc2 = xml { root {
            a2 { b1 }
            a3 { b1 }
          } }
        match_set = new_fast_matched(doc1, doc2)
        match_set.pairs.detect {|match| match.first == doc1.at_css("b1")}.last.name.should == "b1"
      end
    end

    context "one match's parent is same-named" do
      it "matches the node with the same-named parent" do
        doc1 = xml { root {
            a2 { b1 "hello there" ; b2 }
          } }
        doc2 = xml { root {
            a1 { b1 "hello there" }
            a2 { b1 "hello there" }
            a3 { b1 "hello there" }
          } }
        match_set = new_fast_matched(doc1, doc2)
        match_set.pairs.should include([doc1.at_css("a2"), doc2.at_css("a2")])
      end
    end

    context "multiple matches' parents are same-named" do
      it "matches the node with the same-named grandparent" do
        doc1 = xml { root {
            wrap2 {
              a1 { b1 { 10.times { c1 "hello there" } } ; b2 }
            } } }
        doc2 = xml { root {
            wrap1 {
              a1 { b1 { 10.times { c1 "hello there" } } }
            }
            wrap2 {
              a1 { b1 { 10.times { c1 "hello there" } } }
            }
            wrap3 {
              a1 { b1 { 10.times { c1 "hello there" } } }
            } } }
        match_set = new_fast_matched(doc1, doc2)
        match_set.pairs.should include([doc1.at_css("wrap2"), doc2.at_css("wrap2")])
      end
    end
  end
end
