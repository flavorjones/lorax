$VERBOSE = true

require 'rubygems'
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'diffaroo'

warn "#{__FILE__}:#{__LINE__}: libxml version info: #{Nokogiri::VERSION_INFO.inspect}"

module Diffaroo
  class TestCase < Test::Unit::TestCase
    unless RUBY_VERSION >= '1.9'
      undef :default_test
    end
  end
end
