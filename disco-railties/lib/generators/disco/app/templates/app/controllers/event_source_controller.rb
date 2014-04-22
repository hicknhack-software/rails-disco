class EventSourceController < ApplicationController
  include ActionController::Live

  def projected
    response.headers['Content-Type'] = 'text/event-stream'
    sse = ActiveEvent::SSE.new(response.stream)
    ActiveEvent::EventSourceServer.after_event_projection event_id, projection do
      sse.write(nil, event: 'projected')
    end
  rescue IOError
    # ignored
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
