$:.unshift File.expand_path('..', __FILE__)
require "tasks/release"

desc "Build gem files for all projects"
task :build => "all:build"

desc "Release all gems to rubygems and create a tag"
task :release => "all:release"

desc "Run all tests"
task :test do
	sh "cd active_event && bundle exec rspec"
	sh "cd active_projection && bundle exec rspec"
	sh "cd active_domain && bundle exec rspec"
end