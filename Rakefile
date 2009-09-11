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
