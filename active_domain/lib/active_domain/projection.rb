module ActiveDomain
  module Projection
    extend ActiveSupport::Concern

    included do
      ProjectionRegistry.register(self)
    end

  end
end
