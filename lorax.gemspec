# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "lorax"
  s.version = "0.2.0.20121012081020"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mike Dalessio"]
  s.date = "2012-10-12"
  s.description = "The Lorax is a full diff and patch library for XML/HTML documents, based on Nokogiri.\n\nIt can tell you whether two XML/HTML documents are identical, or if\nthey're not, tell you what's different. In trivial cases, it can even\napply the patch.\n\nIt's based loosely on Gregory Cobena's master's thesis paper, which\ngenerates deltas in less than O(n * log n) time, accepting some\ntradeoffs in the size of the delta set. You can find his paper at\nhttp://gregory.cobena.free.fr/www/Publications/thesis.html.\n\n\"I am the Lorax, I speak for the trees.\""
  s.email = ["mike.dalessio@gmail.com"]
  s.executables = ["lorax"]
  s.extra_rdoc_files = ["CHANGELOG.rdoc", "Manifest.txt", "README.rdoc", "README.rdoc", "CHANGELOG.rdoc"]
  s.files = ["CHANGELOG.rdoc", "LICENSE", "Manifest.txt", "README.rdoc", "Rakefile", "TODO", "bin/lorax", "lib/lorax.rb", "lib/lorax/delta.rb", "lib/lorax/delta/delete_delta.rb", "lib/lorax/delta/insert_delta.rb", "lib/lorax/delta/modify_delta.rb", "lib/lorax/delta_set.rb", "lib/lorax/delta_set_generator.rb", "lib/lorax/fast_matcher.rb", "lib/lorax/match.rb", "lib/lorax/match_set.rb", "lib/lorax/signature.rb", "spec/fast_matcher_spec.rb", "spec/files/Michael-Dalessio-200909.html", "spec/files/Michael-Dalessio-201001.html", "spec/files/slashdot-1.html", "spec/files/slashdot-2.html", "spec/files/slashdot-3.html", "spec/files/slashdot-4.html", "spec/integration/lorax_spec.rb", "spec/match_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/unit/delta/delete_delta_spec.rb", "spec/unit/delta/insert_delta_spec.rb", "spec/unit/delta/modify_delta_spec.rb", "spec/unit/delta_set_generator_spec.rb", "spec/unit/delta_set_spec.rb", "spec/unit/lorax_spec.rb", "spec/unit/match_set_spec.rb", "spec/unit/signature_spec.rb", ".gemtest"]
  s.homepage = "http://github.com/flavorjones/lorax"
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "lorax"
  s.rubygems_version = "1.8.24"
  s.summary = "The Lorax is a full diff and patch library for XML/HTML documents, based on Nokogiri"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, [">= 1.4"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.10"])
      s.add_development_dependency(%q<rspec>, ["~> 2.11"])
      s.add_development_dependency(%q<rr>, [">= 1.0"])
      s.add_development_dependency(%q<hoe-git>, ["> 0"])
      s.add_development_dependency(%q<hoe-gemspec>, ["> 0"])
      s.add_development_dependency(%q<hoe-bundler>, ["> 0"])
      s.add_development_dependency(%q<hoe>, ["~> 3.1"])
    else
      s.add_dependency(%q<nokogiri>, [">= 1.4"])
      s.add_dependency(%q<rdoc>, ["~> 3.10"])
      s.add_dependency(%q<rspec>, ["~> 2.11"])
      s.add_dependency(%q<rr>, [">= 1.0"])
      s.add_dependency(%q<hoe-git>, ["> 0"])
      s.add_dependency(%q<hoe-gemspec>, ["> 0"])
      s.add_dependency(%q<hoe-bundler>, ["> 0"])
      s.add_dependency(%q<hoe>, ["~> 3.1"])
    end
  else
    s.add_dependency(%q<nokogiri>, [">= 1.4"])
    s.add_dependency(%q<rdoc>, ["~> 3.10"])
    s.add_dependency(%q<rspec>, ["~> 2.11"])
    s.add_dependency(%q<rr>, [">= 1.0"])
    s.add_dependency(%q<hoe-git>, ["> 0"])
    s.add_dependency(%q<hoe-gemspec>, ["> 0"])
    s.add_dependency(%q<hoe-bundler>, ["> 0"])
    s.add_dependency(%q<hoe>, ["~> 3.1"])
  end
end
