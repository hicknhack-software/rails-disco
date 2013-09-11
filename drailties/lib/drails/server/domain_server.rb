#!/usr/bin/env ruby.exe
require 'active_event'
require 'active_domain'
require 'active_record'

ROOT_DIR ||= ENV['ROOT_DIR']

ActiveEvent::Autoload.app_path = File.join ROOT_DIR, 'app'
ActiveDomain::Autoload.app_path = File.join ROOT_DIR, 'domain'

ActiveDomain::Server.base_path = ROOT_DIR
ActiveDomain::Server.run
