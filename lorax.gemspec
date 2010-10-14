# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{lorax}
  s.version = "0.2.0.20101014152127"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mike Dalessio"]
  s.cert_chain = ["/home/miked/.gem/gem-public_cert.pem"]
  s.date = %q{2010-10-14}
  s.default_executable = %q{lorax}
  s.description = %q{The Lorax is a full diff and patch library for XML/HTML documents, based on Nokogiri.

It can tell you whether two XML/HTML documents are identical, or if
they're not, tell you what's different. In trivial cases, it can even
apply the patch.

It's based loosely on Gregory Cobena's master's thesis paper, which
generates deltas in less than O(n * log n) time, accepting some
tradeoffs in the size of the delta set. You can find his paper at
http://gregory.cobena.free.fr/www/Publications/thesis.html.

"I am the Lorax, I speak for the trees."}
  s.email = ["mike.dalessio@gmail.com"]
  s.executables = ["lorax"]
  s.extra_rdoc_files = ["Manifest.txt", "CHANGELOG.rdoc", "README.rdoc"]
  s.files = ["CHANGELOG.rdoc", "LICENSE", "Manifest.txt", "README.rdoc", "Rakefile", "TODO", "bin/lorax", "lib/lorax.rb", "lib/lorax/delta.rb", "lib/lorax/delta/delete_delta.rb", "lib/lorax/delta/insert_delta.rb", "lib/lorax/delta/modify_delta.rb", "lib/lorax/delta_set.rb", "lib/lorax/delta_set_generator.rb", "lib/lorax/fast_matcher.rb", "lib/lorax/match.rb", "lib/lorax/match_set.rb", "lib/lorax/signature.rb", "spec/fast_matcher_spec.rb", "spec/files/Michael-Dalessio-200909.html", "spec/files/Michael-Dalessio-201001.html", "spec/files/slashdot-1.html", "spec/files/slashdot-2.html", "spec/files/slashdot-3.html", "spec/files/slashdot-4.html", "spec/integration/lorax_spec.rb", "spec/match_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/unit/delta/delete_delta_spec.rb", "spec/unit/delta/insert_delta_spec.rb", "spec/unit/delta/modify_delta_spec.rb", "spec/unit/delta_set_generator_spec.rb", "spec/unit/delta_set_spec.rb", "spec/unit/lorax_spec.rb", "spec/unit/match_set_spec.rb", "spec/unit/signature_spec.rb"]
  s.homepage = %q{http://github.com/flavorjones/lorax}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{lorax}
  s.rubygems_version = %q{1.3.7}
  s.signing_key = %q{/home/miked/.gem/gem-private_key.pem}
  s.summary = %q{The Lorax is a full diff and patch library for XML/HTML documents, based on Nokogiri}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, [">= 1.4.0"])
      s.add_development_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_development_dependency(%q<rr>, [">= 0.10.4"])
      s.add_development_dependency(%q<hoe>, [">= 2.6.1"])
    else
      s.add_dependency(%q<nokogiri>, [">= 1.4.0"])
      s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<rr>, [">= 0.10.4"])
      s.add_dependency(%q<hoe>, [">= 2.6.1"])
    end
  else
    s.add_dependency(%q<nokogiri>, [">= 1.4.0"])
    s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<rr>, [">= 0.10.4"])
    s.add_dependency(%q<hoe>, [">= 2.6.1"])
  end
end
