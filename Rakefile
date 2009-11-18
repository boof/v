# coding: utf-8

require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "v"
    gem.summary = %Q{'florian' says: v is talking git.}
    gem.description = %Q{v is for versioned. It's is currently only a threaded wrapper for the git commands or procedures. In the future it should provide a generic interface for diverse VCSs.}
    gem.email = "florian.assmann@email.de"
    gem.requirements << "fastthread"
    gem.homepage = "http://github.com/boof/v"
    gem.authors = ["Florian Aßmann"]
    gem.add_development_dependency "riot", ">= 0"
    gem.add_development_dependency "yard", ">= 0"
    gem.add_dependency 'fastthread', '>= 1.0.7'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
