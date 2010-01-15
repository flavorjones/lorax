require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Diffaroo::FastMatcher do
  describe ".new" do
    context "normal usage" do
      it "takes two arguments" do
        proc { Diffaroo::FastMatcher.new(xml{root})            }.should     raise_error(ArgumentError)
        proc { Diffaroo::FastMatcher.new(xml{root}, xml{root}) }.should_not raise_error(ArgumentError)
      end

      it "builds a MatchSet for the documents" do
        doc1 = xml { root1 }
        doc2 = xml { root2 }
        mock.proxy(Diffaroo::MatchSet).new(doc1, doc2, anything)
        Diffaroo::FastMatcher.new(doc1, doc2)
      end
    end

    context "dependency injection" do
      it "takes an optional third argument for dependency injection" do
        proc { Diffaroo::FastMatcher.new(xml{root}, xml{root}, {:foo => :bar}) }.should_not raise_error(ArgumentError)
      end

      it "will use the value of ':matcher_match_set' for @match_set" do
        matcher = Diffaroo::FastMatcher.new(xml{root}, xml{root}, {:matcher_match_set => :foo})
        matcher.match_set.should == :foo
      end
    end
  end

  describe "basic node matching" do
    context "simple matches" do
      before do
        @doc1 = xml { root1 {
            a1
            b1
          } }
        @doc2 = xml { root2 {
            a1
            b2
          } }
        @signature1 = Diffaroo::Signature.new(@doc1.root)
        @signature1.set_signature(@doc1.at_css("root1"), "root1")
        @signature1.set_signature(@doc1.at_css("a1"), "a1")
        @signature1.set_signature(@doc1.at_css("b1"), "b1")
        @signature2 = Diffaroo::Signature.new(@doc2.root)
        @signature2.set_signature(@doc2.at_css("root2"), "root2")
        @signature2.set_signature(@doc2.at_css("a1"), "a1")
        @signature2.set_signature(@doc2.at_css("b2"), "b2")
      end

      it "matches identical nodes" do
        match_set = Diffaroo::FastMatcher.new(@doc1, @doc2,
          :match_set_signature1 => @signature1,
          :match_set_signature2 => @signature2).match
        assert_perfect_match_exists match_set, @doc1.at_css("a1"), @doc2.at_css("a1")
      end

      it "does not match different nodes" do
        match_set = Diffaroo::FastMatcher.new(@doc1, @doc2,
          :match_set_signature1 => @signature1,
          :match_set_signature2 => @signature2).match
        assert_no_match_exists match_set, @doc1.at_css("b1"), @doc2.at_css("b2")
      end
    end

    context "sibling matches" do
      it "matches all identical siblings" do
        doc1 = xml { root {
            a1_1 ; a1_3 ; a1_5
          } }
        doc2 = xml { root {
            a2_1 ; a2_2 ; a2_3 ; a2_4 ; a2_5
          } }
        signature1 = Diffaroo::Signature.new(doc1.root)
        signature1.set_signature(doc1.at_css("a1_1"), "a1")
        signature1.set_signature(doc1.at_css("a1_3"), "a3")
        signature1.set_signature(doc1.at_css("a1_5"), "a5")

        signature2 = Diffaroo::Signature.new(doc2.root)
        signature2.set_signature(doc2.at_css("a2_1"), "a1")
        signature2.set_signature(doc2.at_css("a2_3"), "a3")
        signature2.set_signature(doc2.at_css("a2_5"), "a5")

        match_set = Diffaroo::FastMatcher.new(doc1, doc2,
          :match_set_signature1 => signature1, :match_set_signature2 => signature2).match
        assert_perfect_match_exists match_set, doc1.at_css("a1_1"), doc2.at_css("a2_1")
        assert_perfect_match_exists match_set, doc1.at_css("a1_3"), doc2.at_css("a2_3")
        assert_perfect_match_exists match_set, doc1.at_css("a1_5"), doc2.at_css("a2_5")
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
        signature1 = Diffaroo::Signature.new(doc1.root)
        signature1.set_signature(doc1.at_css("a1"), "a1")
        signature1.set_signature(doc1.at_css("b1"), "b1")
        signature1.set_signature(doc1.at_css("b2"), "b2")

        signature2 = Diffaroo::Signature.new(doc2.root)
        signature1.set_signature(doc2.at_css("a2"), "a2")
        signature2.set_signature(doc2.at_css("b1"), "b1")
        signature2.set_signature(doc2.at_css("b2"), "b2")

        match_set = Diffaroo::FastMatcher.new(doc1, doc2,
          :match_set_signature1 => signature1, :match_set_signature2 => signature2).match
        assert_perfect_match_exists match_set, doc1.at_css("b1"), doc2.at_css("b1")
        assert_perfect_match_exists match_set, doc1.at_css("b2"), doc2.at_css("b2")
      end
    end

    context "nested matches" do
      before do
        @doc1 = xml { root1 { a1 { b1 } } }
        @doc2 = xml { root2 { a1 { b1 } } }
        @signature1 = Diffaroo::Signature.new(@doc1.root)
        @signature1.set_signature(@doc1.at_css("a1"), "a1")
        @signature1.set_signature(@doc1.at_css("b1"), "b1")
        @signature2 = Diffaroo::Signature.new(@doc2.root)
        @signature2.set_signature(@doc2.at_css("a1"), "a1")
        @signature2.set_signature(@doc2.at_css("b1"), "b2")
      end

      it "matches the root nodes of the largest identical subtree" do
        match_set = Diffaroo::FastMatcher.new(@doc1, @doc2,
          :match_set_signature1 => @signature1, :match_set_signature2 => @signature2).match
        assert_perfect_match_exists match_set, @doc1.at_css("a1"), @doc2.at_css("a1")
      end

      it "does not match children of identical match nodes" do
        match_set = Diffaroo::FastMatcher.new(@doc1, @doc2,
          :match_set_signature1 => @signature1, :match_set_signature2 => @signature2).match
        assert_no_match_exists match_set, @doc1.at_css("b1"), @doc2.at_css("b1")
      end
    end
  end

  describe "forced parent matching" do
    before do
      stub.instance_of(Diffaroo::FastMatcher).propagate_to_parent # we're not testing propagation to parent
    end

    it "forces a match when parent names are the same but attributes are different" do
      doc1 = xml { root { a1(:foo => "bar")   { b1 } } }
      doc2 = xml { root { a1(:bazz => "quux") { b1 } } }
      match_set = Diffaroo::FastMatcher.new(doc1, doc2).match
      assert_perfect_match_exists match_set, doc1.at_css("b1"), doc2.at_css("b1")
      assert_forced_match_exists  match_set, doc1.at_css("a1"), doc2.at_css("a1")
    end

    it "forces a match when parent names and attributes are the same but siblings are different" do
      doc1 = xml { root { a1(:foo => "bar") { b1 ; b2 } } }
      doc2 = xml { root { a1(:foo => "bar") { b1 ; b3 } } }
      match_set = Diffaroo::FastMatcher.new(doc1, doc2).match
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
        match_set = Diffaroo::FastMatcher.new(doc1, doc2).match
        assert_perfect_match_exists match_set, doc1.at_css("b1"), doc2.at_css("b1")
        assert_forced_match_exists  match_set, doc1.at_css("a1"), doc2.at_css("a1")
        assert_forced_match_exists  match_set, doc1.at_css("b2"), doc2.at_css("b2")
        assert_forced_match_exists  match_set, doc1.at_css("b3"), doc2.at_css("b3")
        assert_forced_match_exists  match_set, doc1.at_css("b4"), doc2.at_css("b4")
      end

      it "force matches recursively" do
        doc1 = xml { root { a1 ; a2 { b2 "hello" } } }
        doc2 = xml { root { a1 ; a2 { b2 "goodbye" } } }
        match_set = Diffaroo::FastMatcher.new(doc1, doc2).match
        assert_perfect_match_exists match_set, doc1.at_css("a1"), doc2.at_css("a1")
        assert_forced_match_exists  match_set, doc1.at_css("a2"), doc2.at_css("a2")
        assert_forced_match_exists  match_set, doc1.at_css("b2"), doc2.at_css("b2")
        assert_forced_match_exists  match_set, doc1.at_xpath("//b2/text()"), doc2.at_xpath("//b2/text()")
      end

      it "should match uniquely-named unmatched children" do
        doc1 = xml { root {
            a1 "hello"
            a2 "goodbye"
            a3 "natch"
          } }
        doc2 = xml { root {
            a1 "hello"
            a3 "not"
          } }
        match_set = Diffaroo::FastMatcher.new(doc1, doc2).match
        assert_perfect_match_exists match_set, doc1.at_css("a1"), doc2.at_css("a1")
        assert_forced_match_exists match_set,  doc1.at_css("a3"), doc2.at_css("a3")
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
        match_set = Diffaroo::FastMatcher.new(doc1, doc2).match
        assert_forced_match_exists match_set, doc1.at_xpath("/root/a1/text()[1]"), doc2.at_xpath("/root/a1/text()[1]")
        assert_forced_match_exists match_set, doc1.at_xpath("/root/a1/text()[2]"), doc2.at_xpath("/root/a1/text()[2]")
      end

      it "large subtree matches force more parent matches than smaller subtree matches" do
        small_doc1 = xml { root { a1 { b1 { c1 { d1 { e1 {
                      f1
                      f2
                    } } } } } } }
        small_doc2 = xml { root { a1 { b1 { c1 { d1 { e1 {
                      f1
                      f3
                    } } } } } } }
        large_doc1 = xml { root { a1 { b1 { c1 { d1 { e1 {
                      f1
                      f2
                    } } } } } } }
        large_doc2 = xml { root { a1 { b1 { c1 { d1 { e1 {
                      f1
                      f3
                    } } } } } } }

        small_signature1 = Diffaroo::Signature.new(small_doc1.root)
        small_signature1.set_weight(small_doc1.at_css("f1"), 1)
        small_signature2 = Diffaroo::Signature.new(small_doc2.root)
        small_signature2.set_weight(small_doc2.at_css("f1"), 1)
        large_signature1 = Diffaroo::Signature.new(large_doc1.root)
        large_signature1.set_weight(large_doc1.at_css("f1"), 10)
        large_signature2 = Diffaroo::Signature.new(large_doc2.root)
        large_signature2.set_weight(large_doc2.at_css("f1"), 10)

        small_match_set = Diffaroo::FastMatcher.new(small_doc1, small_doc2,
          :match_set_signature1 => small_signature1, :match_set_signature2 => small_signature2).match
        large_match_set = Diffaroo::FastMatcher.new(large_doc1, large_doc2,
          :match_set_signature1 => large_signature1, :match_set_signature2 => large_signature2).match

        assert_forced_match_exists small_match_set, small_doc1.at_css("e1"), small_doc2.at_css("e1")
        assert_no_match_exists     small_match_set, small_doc1.at_css("d1"), small_doc2.at_css("d1")

        assert_forced_match_exists large_match_set, large_doc1.at_css("e1"), large_doc2.at_css("e1")
        assert_forced_match_exists large_match_set, large_doc1.at_css("d1"), large_doc2.at_css("d1")
        assert_forced_match_exists large_match_set, large_doc1.at_css("c1"), large_doc2.at_css("c1")
        assert_no_match_exists     large_match_set, large_doc1.at_css("b1"), large_doc2.at_css("b1")
      end
    end
  end

  describe "propagating matches to unmatched parents based on children's matches' parents" do
    context "when there is only one child" do
      it "should match parents all the way up the tree" do
        doc1 = xml { root { a1 { b1 { c1 { d1 { e1 {
                      f1 "hello"
                      f2
                    } } } } } } }
        doc2 = xml { root { a1 { b1 { c1 { d1 { e1 {
                      f1 "hello"
                      f3
                    } } } } } } }
        match_set = Diffaroo::FastMatcher.new(doc1, doc2).match
        assert_perfect_match_exists match_set, doc1.at_css("f1"), doc2.at_css("f1")
        %w[e1 d1 c1 b1 a1 root].each do |node_name|
          assert_forced_match_exists match_set, doc1.at_css(node_name), doc2.at_css(node_name)
        end
      end
    end

    context "there are many possible children" do
      it "should match via children with largest weight" do
        doc1 = xml { root {
            a1 { b1 ; b2 }
          } }
        doc2 = xml { root {
            a1 { b1 ; b3 }
            a1 { b2 ; b4 }
          } }
        signature1 = Diffaroo::Signature.new(doc1.root)
        signature2 = Diffaroo::Signature.new(doc2.root)
        signature1.set_weight(doc1.at_css("b1"), 10)
        signature1.set_weight(doc1.at_css("b2"), 100)
        signature2.set_weight(doc2.at_css("b1"), 10)
        signature2.set_weight(doc2.at_css("b2"), 100)

        match_set = Diffaroo::MatchSet.new(doc1, doc2, :match_set_signature1 => signature1, :match_set_signature2 => signature2)
        match_set.add Diffaroo::Match.new(doc1.at_css("b1"), doc2.at_css("b1"))
        match_set.add Diffaroo::Match.new(doc1.at_css("b2"), doc2.at_css("b2"))

        match_set = Diffaroo::FastMatcher.new(doc1, doc2, :matcher_match_set => match_set).match
        assert_forced_match_exists match_set, doc1.at_css("a1"), doc2.at_xpath("//a1[2]")
      end
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
        signature1 = Diffaroo::Signature.new(doc1.root)
        signature2 = Diffaroo::Signature.new(doc2.root)
        signature1.set_signature(doc1.at_xpath("//b1"),    "b1")
        signature2.set_signature(doc2.at_xpath("//a2/b1"), "b1")
        signature2.set_signature(doc2.at_xpath("//a3/b1"), "b1")
        match_set = Diffaroo::FastMatcher.new(doc1, doc2,
          :match_set_signature1 => signature1, :match_set_signature2 => signature2).match
        match_set.match(doc1.at_css("b1")).other(doc1.at_css("b1")).name.should == "b1"
      end
    end

    context "one match's parent is same-named" do
      it "matches the node with the same-named parent" do
        doc1 = xml { root {
            a2 { b1 ; b2 }
          } }
        doc2 = xml { root {
            a1 { b1 }
            a2 { b1 }
            a3 { b1 }
          } }
        match_set = Diffaroo::FastMatcher.new(doc1, doc2).match
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
        match_set = Diffaroo::FastMatcher.new(doc1, doc2).match
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
        match_set = Diffaroo::FastMatcher.new(doc1, doc2).match
        assert_forced_match_exists match_set, doc1.at_css("wrap2"), doc2.at_css("wrap2")
      end
    end
  end
end
