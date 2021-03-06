# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mp-gwo}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alex MacCaw", "Daniel Bornkessel", "Johannes Mentz", "Yan Minagawa", "Benjamin Krause"]
  s.date = %q{2011-03-28}
  s.description = %q{Google Website Optimizer Helper}
  s.email = %q{github@moviepilot.com}
  s.extra_rdoc_files = [
    "README.markdown"
  ]
  s.files = [
    "MIT-LICENSE",
    "README.markdown",
    "Rakefile",
    "VERSION",
    "gwo.gemspec",
    "lib/gwo.rb",
    "rails/init.rb",
    "spec/lib/gwo_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/moviepilot/gwo}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.5.0}
  s.summary = %q{Google Website Optimizer Helper}
  s.test_files = [
    "spec/lib/gwo_spec.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rspec>, ["~> 1.3"])
      s.add_runtime_dependency(%q<rspec-rails>, ["~> 1.3"])
      s.add_runtime_dependency(%q<rails>, ["= 2.3.11"])
      s.add_runtime_dependency(%q<jeweler>, ["~> 1.5.2"])
    else
      s.add_dependency(%q<rspec>, ["~> 1.3"])
      s.add_dependency(%q<rspec-rails>, ["~> 1.3"])
      s.add_dependency(%q<rails>, ["= 2.3.11"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
    end
  else
    s.add_dependency(%q<rspec>, ["~> 1.3"])
    s.add_dependency(%q<rspec-rails>, ["~> 1.3"])
    s.add_dependency(%q<rails>, ["= 2.3.11"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
  end
end

