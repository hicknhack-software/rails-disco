require 'singleton'

module ActiveProjection
  class ProjectionTypeRegistry
    include Singleton

    def self.register(projection)
      self.registry << projection
    end

    def self.process(headers, event)
      instance.process headers, event
    end

    def process(headers, event)
      projections.each do |projection|
        ActiveRecord::Base.transaction do
          projection.invoke(event, headers) if projection.evaluate headers
        end
      end
    end

    private

    cattr_accessor :registry
    attr_accessor :projections

    def initialize
      self.projections = []
      self.class.registry.freeze.each do |projection|
        projections << projection.new
      end
      projections.freeze
    end

    self.registry = []
  end
end