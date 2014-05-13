module ActiveProjection
  class ProjectionRepository
    def self.last_ids
      Projection.all.to_a.map { |p| p.last_id }
    end

    def self.last_id(id)
      Projection.find(id).last_id
    end

    def self.set_last_id(id, last_id)
      Projection.find(id).update! last_id: last_id
    end

    def self.mark_broken(id)
      Projection.find(id).update! solid: false
    end

    def self.all_broken
      Projection.where(solid: false).to_a.map { |p| p.class_name }
    end

    def self.solid?(id)
      Projection.find(id).solid
    end

    def self.ensure_exists(projection_class)
      Projection.transaction do
        Projection.find_or_create_by! class_name: projection_class
      end
    end

    def self.ensure_solid(projection_class)
      Projection.transaction do
        projection = Projection.find_or_initialize_by class_name: projection_class
        projection.update! solid: true
      end
    end

    private

    def initialize
    end
  end
end
