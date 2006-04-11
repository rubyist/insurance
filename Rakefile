require 'rake/clean'
require 'rake/testtask'
require 'rake/rdoctask'
begin
  require 'rubygems'
  require 'rake/gempackagetask'
rescue Exception
  nil
end

PKG_VERSION = "0.3.4"

desc "Default Task"
task :default => :test

CLEAN.include('**/*.o')

Rake::TestTask.new do |t|
  t.test_files = FileList['test/test*.rb']
  t.warning = true
  t.verbose = true
end

desc "Install the application"
task :install do
  ruby 'install.rb'
end

PKG_FILES = FileList[
  'extconf.rb',
  'insurance_tracer.c',
  'bin/**/*',
  'lib/**/**/*',
  'test/**/*.rb'
]

if ! defined?(Gem)
  puts "Package Target requires RubyGEMs"
else
  spec = Gem::Specification.new do |s|
    s.name              = 'insurance'
    s.version           = PKG_VERSION
    s.summary           = "Code coverage analysis package."
    s.description       = <<-EOF
      Insurance is a code coverage analysis utility.
    EOF
    
    s.files             = PKG_FILES.to_a
    
    s.require_path      = 'lib'
    s.bindir            = 'bin'
    s.executables       = %(railscov)
    
    s.has_rdoc          = false
    
    s.author            = 'Scott Barron'
    s.email             = 'scott@elitists.net'
    s.homepage          = 'http://lunchboxsoftware.com/insurance'
    s.rubyforge_project = 'insurance'
    s.extensions        = %(extconf.rb)
    s.add_dependency    %q<syntax>, [">= 1.0.0"]
  end
  
  package_task = Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_zip = true
    pkg.need_tar = true
  end
end
