# -*- ruby -*-

require 'rubygems'
gem 'hoe', '>= 2.5.0'
require 'hoe'

Hoe.plugin :git

Hoe.spec 'lorax' do
  developer "Mike Dalessio", "mike.dalessio@gmail.com"

  self.extra_rdoc_files = FileList["*.rdoc"]
  self.history_file     = "CHANGELOG.rdoc"
  self.readme_file      = "README.rdoc"

  extra_deps << ["nokogiri", ">= 1.4.0"]
  extra_dev_deps << ["rspec", ">= 1.2.9"]
  extra_dev_deps << ["rr", ">= 0.10.4"]
end

task :redocs => :fix_css
task :docs => :fix_css
task :fix_css do
  better_css = <<-EOT
    .method-description pre {
      margin                    : 1em 0 ;
    }

    .method-description ul {
      padding                   : .5em 0 .5em 2em ;
    }

    .method-description p {
      margin-top                : .5em ;
    }

    #main ul, div#documentation ul {
      list-style-type           : disc ! IMPORTANT ;
      list-style-position       : inside ! IMPORTANT ;
    }

    h2 + ul {
      margin-top                : 1em;
    }
  EOT
  puts "* fixing css"
  File.open("doc/rdoc.css", "a") { |f| f.write better_css }
end

# vim: syntax=ruby
