module ActiveEvent
  class Event < ActiveRecord::Base
    self.table_name = 'domain_events'
    serialize :data, JSON

    # events are only created inside the domain
    def readonly?
      persisted?
    end

    def event_type
      ActiveEvent::EventType.create_instance(event, data)
    end
  end
end
