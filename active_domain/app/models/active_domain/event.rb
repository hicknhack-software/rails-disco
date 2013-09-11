module ActiveDomain
  class Event < ActiveEvent::Event
    self.table_name = 'domain_events'

    # allow write inside the domain
    def readonly?
      @readonly
    end
  end
end
