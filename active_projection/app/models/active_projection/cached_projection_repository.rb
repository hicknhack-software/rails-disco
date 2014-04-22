module ActiveProjection
  #
  # This implements a fully cached projection repository.
  #
  # notice: NOT thread safe!
  class CachedProjectionRepository
    def self.last_ids
      projections.values.map(&:last_id)
    end

    def self.get_last_id(id)
      projections[id].last_id
    end

    def self.set_last_id(id, last_id)
      projections[id].update! last_id: last_id
    end

    def self.set_broken(id)
      projections[id].update! solid: false
    end

    def self.get_all_broken
      projections.values.reject(&:solid).map(&:class_name)
    end

    def self.solid?(id)
      projections[id].solid
    end

    def self.ensure_exists(projection_class)
      Projection.transaction do
        projection = Projection.find_or_create_by! class_name: projection_class
        projections[projection.id] = projection
      end
    end

    def self.ensure_solid(projection_class)
      Projection.transaction do
        projection = Projection.find_or_initialize_by class_name: projection_class
        projection.update! solid: true
        projections[projection.id] = projection
      end
    end

    private

    def self.initialize
    end

    cattr_accessor :projections do
      {}
    end
  end
end
