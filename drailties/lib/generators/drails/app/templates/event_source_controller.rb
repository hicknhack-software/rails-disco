class EventSourceController < ApplicationController
  include ActionController::Live
  include ActiveEvent::EventSourceServer

  def stream
    event_connection.start
    response.headers['Content-Type'] = 'text/event-stream'
    sse = ActiveEvent::SSE.new(response.stream)
    subscribe_to event_queue do |delivery_info, properties, body|
      sse.write({:id => properties.headers['store_id']}, :event => 'refresh')
    end
  rescue IOError
  ensure
    sse.close
  end
end