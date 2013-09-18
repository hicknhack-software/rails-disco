#!/usr/bin/env ruby.exe
require 'active_event'
require 'active_projection'
require 'active_record'

ROOT_DIR ||= ENV['ROOT_DIR']
WORKER_COUNT = [ENV['WORKER_COUNT'].to_i, 1].max
WORKER_NUMBER = ENV['WORKER_NUMBER'].to_i

ActiveEvent::Autoload.app_path = ROOT_DIR
ActiveProjection::Autoload.app_path = ROOT_DIR
ActiveProjection::Autoload.worker_config = {path: ROOT_DIR, count: WORKER_COUNT, number: WORKER_NUMBER}

watchable_dirs = ActiveEvent::Autoload.watchable_dirs.merge ActiveProjection::Autoload.watchable_dirs
RELOADER = ActiveSupport::FileUpdateChecker.new([], watchable_dirs) do
  ActiveEvent::Autoload.reload_module :ValidationsRegistry
  ActiveProjection::Autoload.reload_module :ProjectionTypeRegistry
  ActiveEvent::Autoload.reload
  ActiveProjection::Autoload.reload
end
ActiveProjection::Server.base_path = ROOT_DIR
ActiveProjection::Server.run