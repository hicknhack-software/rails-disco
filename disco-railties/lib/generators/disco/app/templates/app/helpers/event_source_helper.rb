module EventSourceHelper
  def event_source(projection)
    ActiveEvent::EventSourceServer.projection_status(projection)
    event_id = read_and_clear_event_id
    if event_id
      content_tag(:div, '',
                  class: 'event-source',
                  data: {href: event_source_path(projection: projection, event: event_id)})
    end
  end
end
