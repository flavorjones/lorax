require 'nokogiri'

module Lorax
  VERSION = "0.3.0.rc2"
  REQUIRED_NOKOGIRI_VERSION = "1.4.0"
  raise LoadError, "lorax requires Nokogiri version #{REQUIRED_NOKOGIRI_VERSION} or higher" unless Gem::Version.new(Nokogiri::VERSION) >= Gem::Version.new(REQUIRED_NOKOGIRI_VERSION)
end

require "lorax/signature"
require "lorax/match"
require "lorax/match_set"
require "lorax/fast_matcher"

require "lorax/delta"
require "lorax/delta_set_generator"
require "lorax/delta_set"

module Lorax
  def Lorax.diff(string_or_io_or_nokogiridoc_1, string_or_io_or_nokogiridoc_2)
    doc1      = documentize string_or_io_or_nokogiridoc_1
    doc2      = documentize string_or_io_or_nokogiridoc_2

    Lorax::FastMatcher.new(doc1, doc2).match.to_delta_set
  end

  private

  def Lorax.documentize(string_or_io_or_nokogiridoc)
    if string_or_io_or_nokogiridoc.is_a?(Nokogiri::XML::Document)
      string_or_io_or_nokogiridoc
    else
      Nokogiri string_or_io_or_nokogiridoc
    end
  end
end
