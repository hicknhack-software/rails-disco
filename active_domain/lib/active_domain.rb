require 'active_event'
require 'active_support/core_ext'
require 'active_domain/version'

module ActiveDomain
  extend ActiveSupport::Autoload

  autoload :Autoload
  autoload :CommandProcessor
  autoload :CommandRoutes
  autoload :Projection
  autoload :ProjectionRegistry
  autoload :Server

  autoload :Event, (File.expand_path '../../app/models/active_domain/event', __FILE__)
  autoload :EventRepository, (File.expand_path '../../app/models/active_domain/event_repository',__FILE__)
end
