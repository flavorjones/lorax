require 'helper'

module Diffaroo
  class TestHash < Diffaroo::TestCase
    def xml(&block)
      Nokogiri::XML::Builder.new(&block).doc
    end

    def assert_node_hash_equal(node1, node2)
      assert_equal Diffaroo::Hash.node_hash(node1),
                   Diffaroo::Hash.node_hash(node2)
    end

    def assert_node_hash_not_equal(node1, node2)
      assert_not_equal Diffaroo::Hash.node_hash(node1),
                       Diffaroo::Hash.node_hash(node2)
    end

    context "API" do
      context "node_hash" do
        should "raise an error if passed a non-Node" do
          assert_raises(ArgumentError) { Diffaroo::Hash.node_hash(nil) }
        end
      end
    end

    context "XML" do
      context "identical text nodes" do
        should "hash equally" do
          doc = xml { root {
              span "hello"
              span "hello"
            } }
          assert_node_hash_equal(*doc.css("span").collect { |n| n.children.first })
        end
      end

      context "different text nodes" do
        should "hash differently" do
          doc = xml { root {
              span "hello"
              span "goodbye"
            } }
          assert_node_hash_not_equal(*doc.css("span").collect { |n| n.children.first })
        end
      end

      context "elements with same name (with no attributes and no content)" do
        should "hash equally" do
          doc = xml { root { a1 ; a1 } }
          assert_node_hash_equal(*doc.css("a1"))
        end
      end

      context "elements with different names" do
        should "hash differently" do
          doc = xml { root { a1 ; a2 } }
          assert_node_hash_not_equal doc.at_css("a1"), doc.at_css("a2")
        end
      end

      context "same elements in different docs" do
        should "hash equally" do
          doc1 = xml { root { a1 } }
          doc2 = xml { root { a1 } }
          assert_node_hash_equal doc1.at_css("a1"), doc2.at_css("a1")
        end
      end

      context "elements with same name and content (with no attributes)" do
        context "and content is the same" do
          should "hash equally" do
            doc = xml { root {
                a1 "hello"
                a1 "hello"
              } }
            assert_node_hash_equal(*doc.css("a1"))
          end
        end

        context "and content is not the same" do
          should "hash equally" do
            doc = xml { root {
                a1 "hello"
                a1 "goodbye"
              } }
            assert_node_hash_not_equal(*doc.css("a1"))
          end
        end
      end

      context "elements with same name and children (with no attributes)" do
        context "and children are in the same order" do
          should "hash equally" do
            doc = xml { root {
                a1 { b1 ; b2 }
                a1 { b1 ; b2 }
              } }
            assert_node_hash_equal(*doc.css("a1"))
          end
        end

        context "and children are not in the same order" do
          should "hash differently" do
            doc = xml { root {
                a1 { b1 ; b2 }
                a1 { b2 ; b1 }
              } }
            assert_node_hash_not_equal(*doc.css("a1"))
          end
        end
      end

      context "elements with same name and same attributes (with no content)" do
        should "hash equally" do
          doc = xml { root {
              a1("foo" => "bar", "bazz" => "quux")
              a1("foo" => "bar", "bazz" => "quux")
            } }
          assert_node_hash_equal(*doc.css("a1"))
        end
      end

      context "elements with same name and different attributes (with no content)" do
        should "hash differently" do
          doc = xml { root {
              a1("foo" => "bar", "bazz" => "quux")
              a1("foo" => "123", "bazz" => "456")
            } }
          assert_node_hash_not_equal(*doc.css("a1"))
        end
      end

      context "attributes reverse-engineered to be similar" do
        should "hash differently" do
          doc = xml { root {
              a1("foo" => "bar#{Diffaroo::Hash::SEP}quux")
              a1("foo#{Diffaroo::Hash::SEP}bar" => "quux")
            } }
          assert_node_hash_not_equal(*doc.css("a1"))
        end
      end
    end

    context "HTML" do
      should "write some HTML tests"
    end
  end
end
