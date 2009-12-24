require 'nokogiri'

module Diffaroo
  VERSION = "0.1.0"
  REQUIRED_NOKOGIRI_VERSION = "1.4.0"
  raise LoadError, "diffaroo requires Nokogiri version #{REQUIRED_NOKOGIRI_VERSION} or higher" unless Nokogiri::VERSION >= REQUIRED_NOKOGIRI_VERSION
end

require "diffaroo/signature"
require "diffaroo/match"
require "diffaroo/match_set"
require "diffaroo/fast_matcher"
require "diffaroo/match_optimizer"
