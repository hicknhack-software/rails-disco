require 'singleton'

module ActiveProjection
  class ProjectionTypeRegistry
    include Singleton

    # register a new projection class
    #
    # The best way to create a new projection is using the ProjectionType module
    # This module automatically registers each class
    def self.register(projection)
      self.registry << projection
    end

    # @return an enumerable with all projections
    def self.projections
      instance.projections.each
    end

    def projections
      @projections ||= self.class.registry.freeze.map { |projection_class| projection_class.new }.freeze
    end

    private

    cattr_accessor(:registry) { [] }
  end
end
