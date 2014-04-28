module EventSource
  extend ActiveSupport::Concern
  EVENT_ID_KEY = :event_id

  included do
    helper_method :read_and_clear_event_id
  end
  
  def read_and_clear_event_id
    session.delete EVENT_ID_KEY
  end

  def store_event_id(event_id)
    session[EVENT_ID_KEY] = event_id
  end
end
