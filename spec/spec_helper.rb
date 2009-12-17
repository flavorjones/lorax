require 'rubygems'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'diffaroo'

require 'spec'
require 'spec/autorun'
require 'rr'

warn "#{__FILE__}:#{__LINE__}: libxml version info: #{Nokogiri::VERSION_INFO.inspect}"

module XmlBuilderHelper
  def xml(&block)
    Nokogiri::XML::Builder.new(&block).doc
  end
end

Spec::Runner.configure do |config|
  config.mock_with :rr
  config.include XmlBuilderHelper
end
