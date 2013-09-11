require 'active_projection'
require 'rails'

module ActiveProjection
  class Railtie < Rails::Railtie # :nodoc:
    config.eager_load_namespaces << ActiveProjection
  end
end
