require "bundler/gem_tasks"

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

require "rake/extensiontask"
Rake::ExtensionTask.new("numo/fftw") do |ext|
  ext.lib_dir = "lib/numo"
end

require "yard"
YARD::Rake::YardocTask.new do |t|
  t.before = proc{
    Rake::Task["compile:numo/fftw"].invoke
  }
  t.files = Dir['**/numo/fftw/**/fftw.c', __dir__]
  t.options = ['--embed-mixins']
  #t.stats_options = ['--list-undoc']
end

task :default => [:compile, :spec]
