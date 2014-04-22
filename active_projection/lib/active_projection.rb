require 'active_event'
require 'active_support/core_ext'
require 'active_projection/version'

module ActiveProjection
  extend ActiveSupport::Autoload

  autoload :Autoload
  autoload :EventClient
  autoload :ProjectionType
  autoload :ProjectionTypeRegistry
  autoload :Server

  autoload :Projection, (File.expand_path '../../app/models/active_projection/projection', __FILE__)
  autoload :ProjectionRepository, (File.expand_path '../../app/models/active_projection/projection_repository', __FILE__)
  autoload :CachedProjectionRepository, (File.expand_path '../../app/models/active_projection/cached_projection_repository', __FILE__)
end
