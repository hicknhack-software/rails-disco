require 'yaml'
require 'active_support'
require 'active_support/core_ext'
require 'active_event/version'

module ActiveEvent
  extend ActiveSupport::Autoload

  autoload :Autoload
  autoload :Command
  autoload :Domain
  autoload :EventServer
  autoload :EventSourceServer
  autoload :EventType
  autoload :ReplayServer
  autoload :SSE
  autoload :Validations
  autoload :ValidationsRegistry

  module Support
    extend ActiveSupport::Autoload

    autoload :AttrInitializer
    autoload :AttrSetter
    autoload :Autoload
    autoload :Autoloader
    autoload :MultiLogger
  end

  autoload :Event, (File.expand_path '../../app/models/active_event/event', __FILE__)
  autoload :EventRepository, (File.expand_path '../../app/models/active_event/event_repository', __FILE__)
end
