require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Diffaroo::MatchOptimizer do
  it "finds more matches" do
    doc1 = xml { root { a1 { b1 { c1 { d1 { e1 {
                  f1 "hello"
                  f2
                } } } } } } }
    doc2 = xml { root { a1 { b1 { c1 { d1 { e1 {
                  f1 "hello"
                  f3
                } } } } } } }
    match_set = Diffaroo::MatchSet.new(doc1, doc2)
    match_set.add Diffaroo::Match.new(doc1.at_css("f1"), doc2.at_css("f1"), 0)
    %w(e1 d1 c1 b1 a1 root).each do |name|
      assert_no_match_exists match_set, doc1.at_css(name), doc2.at_css(name)
    end

    Diffaroo::MatchOptimizer.match(match_set)

    %w(e1 d1 c1 b1 a1 root).each do |name|
      assert_match_exists match_set, doc1.at_css(name), doc2.at_css(name)
    end
  end
end
