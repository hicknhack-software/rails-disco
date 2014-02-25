module ActiveProjection
  class ProjectionRepository

    def self.last_ids
      Projection.all.to_a.map { |p| p.last_id }
    end

    def self.get_last_id(id)
      @@last_id[id] ||= Projection.find(id).last_id
    end

    def self.set_last_id(id, last_id)
      Projection.find(id).update! last_id: last_id
      @@last_id[id] += 1
    end

    def self.set_broken(id)
      @@broken[id] = false
      Projection.find(id).update! solid: false
    end

    def self.get_all_broken
      broken_projections = []
      Projection.all.to_a.each do |p|
        broken_projections << p.class_name unless p.solid?
      end
      broken_projections
    end

    def self.solid?(id)
      @@broken[id] ||= Projection.find(id).solid
    end

    def self.create_or_get(projection_class)
      projection = Projection.where(class_name: projection_class).first
      if projection.nil?
        projection = Projection.create! class_name: projection_class, last_id: 0, solid: true
      else
        projection.update! solid: true
      end
      projection
    end

    private
    def self.initialize
    end

    @@last_id = {}
    @@broken = {}
  end
end