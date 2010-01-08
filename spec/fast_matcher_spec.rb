require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Diffaroo::FastMatcher do
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
        match_set = Diffaroo::FastMatcher.match(@doc1, @doc2)
        assert_perfect_match_exists match_set, @doc1.at_css("a1"), @doc2.at_css("a1")
      end

      it "does not match different nodes" do
        match_set = Diffaroo::FastMatcher.match(@doc1, @doc2)
        assert_no_match_exists match_set, @doc1.at_css("b1"), @doc2.at_css("b2")
      end
    end

    context "sibling matches" do
      it "matches all siblings" do
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
        match_set = Diffaroo::FastMatcher.match(doc1, doc2)
        assert_perfect_match_exists match_set, doc1.at_css("a1"), doc2.at_css("a1")
        assert_perfect_match_exists match_set, doc1.at_css("a3"), doc2.at_css("a3")
        assert_perfect_match_exists match_set, doc1.at_css("a5"), doc2.at_css("a5")
      end
    end

    context "matching children of an unmatched node" do
      it "matches those children" do
        doc1 = xml { root {
            a1 {
              b1 ; b2
            }
          } }
        doc2 = xml { root {
            a2 {
              b1 ; b2
            }
          } }
        match_set = Diffaroo::FastMatcher.match(doc1, doc2)
        assert_perfect_match_exists match_set, doc1.at_css("b1"), doc2.at_css("b1")
        assert_perfect_match_exists match_set, doc1.at_css("b2"), doc2.at_css("b2")
      end
    end

    context "nested matches" do
      before do
        @doc1 = xml { root1 { a1 { b1 "hello" } } }
        @doc2 = xml { root2 { a1 { b1 "hello" } } }
      end

      it "matches the root nodes of the largest identical subtree" do
        match_set = Diffaroo::FastMatcher.match(@doc1, @doc2)
        assert_perfect_match_exists match_set, @doc1.at_css("a1"), @doc2.at_css("a1")
      end

      it "does not match children of identical match nodes" do
        match_set = Diffaroo::FastMatcher.match(@doc1, @doc2)
        assert_no_match_exists match_set, @doc1.at_css("b1"), @doc2.at_css("b1")
      end
    end
  end

  describe "forced parent matching" do
    it "forces a match when parent names are the same but attributes are different" do
      doc1 = xml { root { a1(:foo => "bar")   { b1 } } }
      doc2 = xml { root { a1(:bazz => "quux") { b1 } } }
      match_set = Diffaroo::FastMatcher.match(doc1, doc2)
      assert_perfect_match_exists match_set, doc1.at_css("b1"), doc2.at_css("b1")
      assert_forced_match_exists  match_set, doc1.at_css("a1"), doc2.at_css("a1")
    end

    it "forces a match when parent names and attributes are the same but siblings are different" do
      doc1 = xml { root { a1(:foo => "bar") { b1 "hello" ; b2 } } }
      doc2 = xml { root { a1(:foo => "bar") { b1 "hello" ; b3 } } }
      match_set = Diffaroo::FastMatcher.match(doc1, doc2)
      assert_perfect_match_exists match_set, doc1.at_css("b1"), doc2.at_css("b1")
      assert_forced_match_exists  match_set, doc1.at_css("a1"), doc2.at_css("a1")
    end

    describe "subsequent forced child matching" do
      it "force matches a uniquely-named sibling" do
        doc1 = xml { root { a1 {
              b2 "goodbye"
              b1 "hello"
              b3
              b4
            } } }
        doc2 = xml { root { a1 {
              b2 "good boy"
              b1 "hello"
              b3 "something"
              b4 { c1 }
            } } }
        match_set = Diffaroo::FastMatcher.match(doc1, doc2)
        assert_perfect_match_exists match_set, doc1.at_css("b1"), doc2.at_css("b1")
        assert_forced_match_exists  match_set, doc1.at_css("a1"), doc2.at_css("a1")
        assert_forced_match_exists  match_set, doc1.at_css("b2"), doc2.at_css("b2")
        assert_forced_match_exists  match_set, doc1.at_css("b3"), doc2.at_css("b3")
        assert_forced_match_exists  match_set, doc1.at_css("b4"), doc2.at_css("b4")
      end

      it "force matches recursively" do
        doc1 = xml { root { a1 ; a2 { b2 "hello" } } }
        doc2 = xml { root { a1 ; a2 { b2 "goodbye" } } }
        match_set = Diffaroo::FastMatcher.match(doc1, doc2)
        assert_perfect_match_exists match_set, doc1.at_css("a1"), doc2.at_css("a1")
        assert_forced_match_exists  match_set, doc1.at_css("a2"), doc2.at_css("a2")
        assert_forced_match_exists  match_set, doc1.at_css("b2"), doc2.at_css("b2")
        assert_forced_match_exists  match_set, doc1.at_xpath("//b2/text()"), doc2.at_xpath("//b2/text()")
      end

      it "should match uniquely-named unmatched children" do
        doc1 = xml { root {
            a1 {
              text "hello"
              b1 "foo"
              text "goodbye"
            }
          } }
        doc2 = xml { root {
            a1 {
              text "halloo"
              b1 "foo"
              text "goodbye"
            }
          } }
        match_set = Diffaroo::FastMatcher.match(doc1, doc2)
        assert_forced_match_exists match_set, doc1.at_xpath("/root/a1/text()[1]"), doc2.at_xpath("/root/a1/text()[1]")
      end

      it "should match same-named children in the same position, even if they are not uniquely named" do
        doc1 = xml { root {
            a1 {
              text "hello"
              b1 "foo"
              text "goodbye"
            }
          } }
        doc2 = xml { root {
            a1 {
              text "bonjour"
              b1 "foo"
              text "au revoir"
            }
          } }
        match_set = Diffaroo::FastMatcher.match(doc1, doc2)
        assert_forced_match_exists match_set, doc1.at_xpath("/root/a1/text()[1]"), doc2.at_xpath("/root/a1/text()[1]")
        assert_forced_match_exists match_set, doc1.at_xpath("/root/a1/text()[2]"), doc2.at_xpath("/root/a1/text()[2]")
      end
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

      small_match_set = Diffaroo::FastMatcher.match(small_doc1, small_doc2)
      large_match_set = Diffaroo::FastMatcher.match(large_doc1, large_doc2)

      assert_forced_match_exists small_match_set, small_doc1.at_css("e1"), small_doc2.at_css("e1")
      assert_no_match_exists     small_match_set, small_doc1.at_css("d1"), small_doc2.at_css("d1")

      assert_forced_match_exists large_match_set, large_doc1.at_css("e1"), large_doc2.at_css("e1")
      assert_forced_match_exists large_match_set, large_doc1.at_css("d1"), large_doc2.at_css("d1")
      assert_forced_match_exists large_match_set, large_doc1.at_css("c1"), large_doc2.at_css("c1")
      assert_no_match_exists     large_match_set, large_doc1.at_css("b1"), large_doc2.at_css("b1")
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
        match_set = Diffaroo::FastMatcher.match(doc1, doc2)
        match_set.match(doc1.at_css("b1")).other(doc1.at_css("b1")).name.should == "b1"
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
        match_set = Diffaroo::FastMatcher.match(doc1, doc2)
        assert_forced_match_exists match_set, doc1.at_css("a2"), doc2.at_css("a2")
      end
    end

    context "multiple identical nodes exist in both documents" do
      it "should create one-to-one match relationships" do
        doc1 = xml { root1 {
            a1 ; a1 ; a1
          } }
        doc2 = xml { root2 {
            a1 ; a1
          } }
        match_set = Diffaroo::FastMatcher.match(doc1, doc2)
        [doc1, doc2].each do |doc|
          others = doc.css("a1").collect do |node|
            m = match_set.match(node)
            m ? m.pair.last : nil
          end
          others.uniq.length.should == others.length
        end
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
        match_set = Diffaroo::FastMatcher.match(doc1, doc2)
        assert_forced_match_exists match_set, doc1.at_css("wrap2"), doc2.at_css("wrap2")
      end
    end
  end
end
