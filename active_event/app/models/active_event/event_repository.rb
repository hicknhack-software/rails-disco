module ActiveEvent
  class EventRepository
    def self.ordered
      ActiveEvent::Event.order(:id)
    end

    def self.after_id(id)
      ordered.where ActiveEvent::Event.arel_table['id'].gt(id)
    end
  end
end
