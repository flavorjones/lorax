require 'rubygems'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'diffaroo'

require 'spec'
require 'spec/autorun'
require 'rr'

warn "#{__FILE__}:#{__LINE__}: libxml version info: #{Nokogiri::VERSION_INFO.inspect}"

Spec::Runner.configure do |config|
  config.mock_with :rr
end
