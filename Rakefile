require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'spec/rake/spectask'

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
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Gwo'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc 'Build gem'
task :build do
  system "gem build gwo.gemspec"
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

