require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'spec/rake/spectask'
require 'bundler'

desc 'Default: run unit tests.'
task :default => :rspec

# ... we are too stupid to get this running 
#desc "Run all examples"
#Spec::Rake::SpecTask.new('rspec') do |t|
#    t.spec_files = FileList['spec/**/*_spec.rb']
#end

desc "Run rspec tests"
task :rspec do
  system "spec spec"
end

desc 'Generate documentation for the gwo plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = 'Gwo'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.markdown')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc 'Install latest gem'
task :install_only do
  system "gem install $( ls -t -1 *.gem | head -n 1 )"
end

desc 'Build and install gem' 
task :install do
  system "gem build gwo.gemspec"
  system "gem install $( ls -t -1 *.gem | head -n 1 )"
end

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "mp-gwo"
  gem.homepage = "http://github.com/moviepilot/gwo"
  gem.license = "MIT"
  gem.summary = %Q{Google Website Optimizer Helper}
  gem.description = %Q{Google Website Optimizer Helper}
  gem.email = "github@moviepilot.com"
  gem.authors = ["Alex MacCaw", "Daniel Bornkessel", "Johannes Mentz", "Yan Minagawa", "Benjamin Krause"]
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  #  gem.add_runtime_dependency 'jabber4r', '> 0.1'
  #  gem.add_development_dependency 'rspec', '> 1.2.3'
end
Jeweler::RubygemsDotOrgTasks.new
