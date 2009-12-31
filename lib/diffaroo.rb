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

require "diffaroo/delta"
require "diffaroo/delta_set_generator"
require "diffaroo/delta_set"

module Diffaroo
  def Diffaroo.diff(string_or_io_or_nokogiridoc_1, string_or_io_or_nokogiridoc_2)
    doc1      = documentize string_or_io_or_nokogiridoc_1
    doc2      = documentize string_or_io_or_nokogiridoc_2

    Diffaroo::FastMatcher.match(doc1, doc2).to_delta_set
  end

  private

  def Diffaroo.documentize(string_or_io_or_nokogiridoc)
    if string_or_io_or_nokogiridoc.is_a?(Nokogiri::XML::Document)
      string_or_io_or_nokogiridoc
    else
      Nokogiri::XML string_or_io_or_nokogiridoc
    end
  end
end
