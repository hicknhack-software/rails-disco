module ActiveDomain
  class EventRepository

    def self.ordered
      ActiveDomain::Event.order(:id)
    end

    def self.after_id(id)
      ordered.where ActiveDomain::Event.arel_table['id'].gt(id)
    end

    def self.store(event)
      stored_event = ActiveDomain::Event.create!(event: event.class.name, data: event.to_hash)
      event.add_store_infos id: stored_event.id, created_at: stored_event.created_at
    end
  end
end
