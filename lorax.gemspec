# -*- encoding: utf-8 -*-
# stub: lorax 0.3.0.rc2.20210907092457 ruby lib

Gem::Specification.new do |s|
  s.name = "lorax".freeze
  s.version = "0.3.0.rc2.20210907092457"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "homepage_uri" => "http://github.com/flavorjones/lorax" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Mike Dalessio".freeze]
  s.date = "2021-09-07"
  s.description = "The Lorax is a full diff and patch library for XML/HTML documents, based on Nokogiri.\n\nIt can tell you whether two XML/HTML documents are identical, or if\nthey're not, tell you what's different. In trivial cases, it can even\napply the patch.\n\nIt's based loosely on Gregory Cobena's master's thesis paper, which\ngenerates deltas in less than O(n * log n) time, accepting some\ntradeoffs in the size of the delta set. You can find his paper at\nhttp://gregory.cobena.free.fr/www/Publications/thesis.html.\n\n\"I am the Lorax, I speak for the trees.\"".freeze
  s.email = ["mike.dalessio@gmail.com".freeze]
  s.executables = ["lorax".freeze]
  s.extra_rdoc_files = ["CHANGELOG.rdoc".freeze, "Manifest.txt".freeze, "README.rdoc".freeze, "CHANGELOG.rdoc".freeze, "README.rdoc".freeze]
  s.files = ["CHANGELOG.rdoc".freeze, "LICENSE".freeze, "Manifest.txt".freeze, "README.rdoc".freeze, "Rakefile".freeze, "TODO".freeze, "bin/lorax".freeze, "lib/lorax.rb".freeze, "lib/lorax/delta.rb".freeze, "lib/lorax/delta/delete_delta.rb".freeze, "lib/lorax/delta/insert_delta.rb".freeze, "lib/lorax/delta/modify_delta.rb".freeze, "lib/lorax/delta_set.rb".freeze, "lib/lorax/delta_set_generator.rb".freeze, "lib/lorax/fast_matcher.rb".freeze, "lib/lorax/match.rb".freeze, "lib/lorax/match_set.rb".freeze, "lib/lorax/signature.rb".freeze, "spec/fast_matcher_spec.rb".freeze, "spec/files/Michael-Dalessio-200909.html".freeze, "spec/files/Michael-Dalessio-201001.html".freeze, "spec/files/slashdot-1.html".freeze, "spec/files/slashdot-2.html".freeze, "spec/files/slashdot-3.html".freeze, "spec/files/slashdot-4.html".freeze, "spec/integration/lorax_spec.rb".freeze, "spec/match_spec.rb".freeze, "spec/spec.opts".freeze, "spec/spec_helper.rb".freeze, "spec/unit/delta/delete_delta_spec.rb".freeze, "spec/unit/delta/insert_delta_spec.rb".freeze, "spec/unit/delta/modify_delta_spec.rb".freeze, "spec/unit/delta_set_generator_spec.rb".freeze, "spec/unit/delta_set_spec.rb".freeze, "spec/unit/lorax_spec.rb".freeze, "spec/unit/match_set_spec.rb".freeze, "spec/unit/signature_spec.rb".freeze]
  s.homepage = "http://github.com/flavorjones/lorax".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--main".freeze, "README.rdoc".freeze]
  s.rubygems_version = "3.2.15".freeze
  s.summary = "The Lorax is a full diff and patch library for XML/HTML documents, based on Nokogiri".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<nokogiri>.freeze, [">= 1.4"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 2.11"])
    s.add_development_dependency(%q<rr>.freeze, [">= 1.0"])
    s.add_development_dependency(%q<hoe-git>.freeze, ["> 0"])
    s.add_development_dependency(%q<hoe-gemspec>.freeze, ["> 0"])
    s.add_development_dependency(%q<hoe-bundler>.freeze, ["> 0"])
    s.add_development_dependency(%q<rdoc>.freeze, [">= 4.0", "< 7"])
    s.add_development_dependency(%q<hoe>.freeze, ["~> 3.23"])
  else
    s.add_dependency(%q<nokogiri>.freeze, [">= 1.4"])
    s.add_dependency(%q<rspec>.freeze, ["~> 2.11"])
    s.add_dependency(%q<rr>.freeze, [">= 1.0"])
    s.add_dependency(%q<hoe-git>.freeze, ["> 0"])
    s.add_dependency(%q<hoe-gemspec>.freeze, ["> 0"])
    s.add_dependency(%q<hoe-bundler>.freeze, ["> 0"])
    s.add_dependency(%q<rdoc>.freeze, [">= 4.0", "< 7"])
    s.add_dependency(%q<hoe>.freeze, ["~> 3.23"])
  end
end
