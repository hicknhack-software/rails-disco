#!/usr/bin/env ruby.exe
ROOT_DIR ||= ENV['ROOT_DIR']
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('Gemfile', ROOT_DIR)
require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

require 'active_event'
require 'active_projection'
require 'active_record'

WORKER_COUNT = [ENV['WORKER_COUNT'].to_i, 1].max
WORKER_NUMBER = ENV['WORKER_NUMBER'].to_i
LOGGER = ActiveEvent::Support::MultiLogger.new "Projection Server#{WORKER_COUNT > 1 ? " Nr. #{WORKER_NUMBER}" : ''}"

ActiveEvent::Autoload.app_path = ROOT_DIR
ActiveProjection::Autoload.app_path = ROOT_DIR

watchable_dirs = ActiveEvent::Autoload.watchable_dirs.merge ActiveProjection::Autoload.watchable_dirs
RELOADER = ActiveSupport::FileUpdateChecker.new([], watchable_dirs) do
  ActiveEvent::Autoload.reload_module :ValidationsRegistry
  ActiveProjection::Autoload.reload_module :ProjectionTypeRegistry
  ActiveEvent::Autoload.reload
  ActiveProjection::Autoload.reload
end
ActiveProjection::Server.base_path = ROOT_DIR
ActiveProjection::Server.run
