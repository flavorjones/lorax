require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Diffaroo::Matcher do
  describe "#new" do
    describe "API" do
      it "(write some specs)"
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
          matcher = Diffaroo::Matcher.new(@doc1, @doc2)
          matcher.matches.should include([@doc1.at_css("a1"), @doc2.at_css("a1")])
        end

        it "does not match different nodes" do
          matcher = Diffaroo::Matcher.new(@doc1, @doc2)
          matcher.matches.flatten.should_not include(@doc1.at_css("b1"))
          matcher.matches.flatten.should_not include(@doc2.at_css("b2"))
        end
      end

      context "nested matches" do
        before do
          @doc1 = xml { root { a1 "hello" } }
          @doc2 = xml { root { a1 "hello" } }
        end

        it "matches the largest identical subtree" do
          matcher = Diffaroo::Matcher.new(@doc1, @doc2)
          matcher.matches.should include([@doc1.at_css("root"), @doc2.at_css("root")])
        end

        it "does not match small nodes within a larger matching subtree" do
          matcher = Diffaroo::Matcher.new(@doc1, @doc2)
          matcher.matches.flatten.should_not include(@doc1.at_css("a1"))
          matcher.matches.flatten.should_not include(@doc2.at_css("a1"))
        end
      end
    end

    describe "forced parent matching" do
      it "forces a match when parent names are the same but attributes are different" do
        doc1 = xml { root { a1(:foo => "bar")   { b1 } } }
        doc2 = xml { root { a1(:bazz => "quux") { b1 } } }
        matcher = Diffaroo::Matcher.new(doc1, doc2)
        matcher.matches.should include([doc1.at_css("a1"), doc2.at_css("a1")])
      end

      it "forces a match when parent names and attributes are the same but siblings are different" do
        doc1 = xml { root { a1(:foo => "bar") { b1 "hello" ; b2 } } }
        doc2 = xml { root { a1(:foo => "bar") { b1 "hello" ; b3 } } }
        matcher = Diffaroo::Matcher.new(doc1, doc2)
        matcher.matches.should include([doc1.at_css("a1"), doc2.at_css("a1")])
      end

      context "large subtree match" do
        it "forces more parent matches"
      end
    end

    describe "choosing the best among multiple matches" do
      context "no match's parent is same-named" do
        it "is currently unspecified"
      end

      context "one match's parent is same-named" do
        it "matches the node with the same-named parent"
      end

      context "multiple matches' parents are same-named" do
        it "matches the node with the same-named grandparent"
      end
    end
  end
end

