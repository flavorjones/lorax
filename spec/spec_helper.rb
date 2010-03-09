require 'rubygems'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'lorax'

require 'spec'
require 'spec/autorun'
require 'rr'
require 'pp'

warn "#{__FILE__}:#{__LINE__}: libxml version info: #{Nokogiri::VERSION_INFO.inspect}"

module XmlBuilderHelper
  def xml(&block)
    Nokogiri::XML::Builder.new(&block).doc
  end

  def assert_no_match_exists(match_set, node1, node2)
    match_set.match(node1).should be_nil
    match_set.match(node2).should be_nil
  end

  def assert_perfect_match_exists(match_set, node1, node2)
    match = match_set.match(node1)
    fail "#{node1.inspect} was not matched" if match.nil?
    match.other(node1).should == node2
    match.should be_perfect
  end

  def assert_forced_match_exists(match_set, node1, node2)
    match = match_set.match(node1)
    fail "#{node1.inspect} was not matched" if match.nil?
    match.other(node1).should == node2
    match.should_not be_perfect
  end
end

Spec::Runner.configure do |config|
  config.mock_with :rr
  config.include XmlBuilderHelper
end
