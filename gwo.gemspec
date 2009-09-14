Gem::Specification.new do |s|
  s.name = "gwo"
  s.version = "0.1.1"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alex MacCaw", "Daniel Bornkessel", "Johannes Mentz", "Yan Minagawa"] 
  s.date = "2009-09-11"
  s.email = "daniel@bornkessel.com"
  s.extra_rdoc_files = %w{ README.markdown }
  s.files = %w{ lib/gwo.rb MIT-LICENSE README.markdown spec/lib/gwo_spec.rb spec/spec_helper.rb rails/init.rb}
  s.has_rdoc = true
  s.rdoc_options = ["--line-numbers", "--inline-source"]
  s.homepage = "http://github.com/kesselborn/gwo"
  s.require_paths = %w{ lib }
  s.rubygems_version = "1.3.1"
  s.summary = "Plugin to easily make use of Server-Side Dynamic Section Variations with Google Web Optimizer"
end
