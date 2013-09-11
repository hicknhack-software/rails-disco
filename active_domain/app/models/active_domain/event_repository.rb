module ActiveDomain
  class EventRepository

    def self.ordered
      ActiveDomain::Event.order(:id)
    end

    def self.after_id(id)
      ordered.where ActiveDomain::Event.arel_table['id'].gt(id)
    end

    def self.store(event)
      stored_event = ActiveDomain::Event.create! event: event.class.name,
                                  data: event,
                                  created_at: DateTime.now
      event.add_store_infos store_id: stored_event.id
    end
  end
end
