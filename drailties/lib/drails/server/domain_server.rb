#!/usr/bin/env ruby.exe
require 'active_event'
require 'active_domain'
require 'active_record'

ROOT_DIR ||= ENV['ROOT_DIR']
LOGGER = ActiveEvent::Support::MultiLogger.new 'Domain Server'

ActiveEvent::Autoload.app_path = ROOT_DIR
ActiveDomain::Autoload.app_path = ROOT_DIR

watchable_dirs = ActiveEvent::Autoload.watchable_dirs.merge ActiveDomain::Autoload.watchable_dirs
RELOADER = ActiveSupport::FileUpdateChecker.new([], watchable_dirs) do
  ActiveEvent::Autoload.reload_module :ValidationsRegistry
  ActiveDomain::Autoload.reload_module :ProjectionRegistry
  ActiveEvent::Autoload.reload
  ActiveDomain::Autoload.reload
  ActiveEvent::ValidationsRegistry.build
end

ActiveEvent::ValidationsRegistry.build
ActiveDomain::Server.base_path = ROOT_DIR
ActiveDomain::Server.run
