require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'webshot/cli'

RSpec::Core::RakeTask.new(:spec)

ARGS = ["capture"]

task :wipe_dirs do
  FileUtils.rm_rf("screenshots")
  FileUtils.rm_rf("diffs")
end

task :capture do
  2.times { Webshot::CLI.start(ARGS) }
end

task :default => [:wipe_dirs, :capture, :spec]
