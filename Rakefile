$LOAD_PATH.unshift File.expand_path('..', __FILE__)
require 'tasks/release'

desc 'Build gem files for all projects'
task build: 'all:build'

desc 'Release all gems to rubygems and create a tag'
task release: 'all:release'

desc 'Run all tests'
task :test do
  %w(active_event active_projection active_domain).each do |gem|
    sh "cd #{gem} && rspec"
  end
end
