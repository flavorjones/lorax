require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Diffaroo::Matcher do
  describe "#new" do
    describe "API" do
      it "builds a Signature for each document root" do
        doc1 = xml { root1 }
        doc2 = xml { root2 }
        mock.proxy(Diffaroo::Signature).new(doc1.root)
        mock.proxy(Diffaroo::Signature).new(doc2.root)
        Diffaroo::Matcher.new(doc1, doc2)
      end

      it "calls match" do
        doc1 = xml { root1 }
        doc2 = xml { root2 }
        mock.proxy.instance_of(Diffaroo::Matcher).match
        Diffaroo::Matcher.new(doc1, doc2)
      end

      it "has a matches accessor"
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

      it "should be unique" do
        large_doc1 = xml { root { a1 { b1 { c1 { d1 { e1 {
                      10.times { f1 "hello" }
                      f2
                    } } } } } } }
        large_doc2 = xml { root { a1 { b1 { c1 { d1 { e1 {
                      10.times { f1 "hello" }
                      f3
                    } } } } } } }
        large_matcher = Diffaroo::Matcher.new(large_doc1, large_doc2)
        large_matcher.matches.size.should == 1
      end

      it "large subtree matches force more parent matches" do
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

        small_matcher = Diffaroo::Matcher.new(small_doc1, small_doc2)
        large_matcher = Diffaroo::Matcher.new(large_doc1, large_doc2)

        small_matcher.matches.should     include([small_doc1.at_css("e1"), small_doc2.at_css("e1")])
        small_matcher.matches.should_not include([small_doc1.at_css("d1"), small_doc2.at_css("d1")])

        large_matcher.matches.should_not include([large_doc1.at_css("e1"), large_doc2.at_css("e1")])
        large_matcher.matches.should_not include([large_doc1.at_css("d1"), large_doc2.at_css("d1")])
        large_matcher.matches.should     include([large_doc1.at_css("c1"), large_doc2.at_css("c1")])
        large_matcher.matches.should_not include([large_doc1.at_css("b1"), large_doc2.at_css("b1")])
      end
    end

    describe "choosing the best among multiple matches" do
      context "no match's parent is same-named" do
        it "is currently unspecified"
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
          matcher = Diffaroo::Matcher.new(doc1, doc2)
          matcher.matches.should include([doc1.at_css("a2"), doc2.at_css("a2")])
        end
      end

      context "multiple matches' parents are same-named" do
        it "matches the node with the same-named grandparent"
      end
    end
  end
end
