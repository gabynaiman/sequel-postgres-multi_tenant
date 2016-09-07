require 'rake/testtask'
require 'bundler/gem_tasks'

Rake::TestTask.new(:spec) do |t|
  t.libs << 'spec'
  t.libs << 'lib'
  t.pattern = 'spec/**/*_spec.rb'
  t.verbose = false
  t.warning = false
end

task default: :spec

desc 'Pry console'
task :console do
  require 'pry-nav'
  require 'sequel-postgres-multi_tenant'
  ARGV.clear
  Pry.start
end