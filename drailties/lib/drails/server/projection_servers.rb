#!/usr/bin/env ruby.exe
require 'active_event'
require 'active_projection'
require 'active_record'

ROOT_DIR ||= ENV['ROOT_DIR']
WORKER_COUNT = [ENV['WORKER_COUNT'].to_i, 1].max
WORKER_NUMBER = ENV['WORKER_NUMBER'].to_i

ActiveEvent::Autoload.app_path = File.join ROOT_DIR, 'app'
ActiveProjection::Autoload.app_path = File.join(ROOT_DIR, 'app')
ActiveProjection::Autoload.worker_config = {path: File.join(ROOT_DIR, 'app', 'projections'), count: WORKER_COUNT, number: WORKER_NUMBER}

ActiveProjection::Server.base_path = ROOT_DIR
ActiveProjection::Server.run