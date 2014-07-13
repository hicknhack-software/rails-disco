class EventSourceController < ApplicationController
  include ActionController::Live

  def projected
    response.headers['Content-Type'] = 'text/event-stream'
    sse = ActiveEvent::SSE.new(response.stream)
    ActiveEvent::EventSourceServer.wait_for_event_projection event_id, projection, timeout: 10
    sse.event('projected')
  rescue IOError
    # ignore disconnect
  rescue ActiveEvent::ProjectionException => e
    sse.event('exception', {error: e.message, backtrace: e.backtrace})
  ensure
    sse.close
  end

  private

  def event_id
    params[:event].to_i
  end

  def projection
    params[:projection]
  end
end
