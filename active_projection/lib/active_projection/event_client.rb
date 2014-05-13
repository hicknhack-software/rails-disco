require 'singleton'
require 'bunny'

module ActiveProjection
  class EventClient
    include Singleton

    def self.start(options)
      instance.configure(options).start
    end

    def configure(options)
      raise 'Unsupported! Cannot configure running client' if running
      self.options = options
      self
    end

    def start
      run_once do
        prepare
        sync_projections
        listen_for_events
        listen_for_replayed_events
        request_missing_events
        event_channel.work_pool.join
      end
    rescue Interrupt
      LOGGER.info 'Catching Interrupt'
    rescue => e
      LOGGER.error e.message
      LOGGER.error e.backtrace.join("\n")
      raise
    end

    private

    attr_accessor :options
    attr_accessor :running # true once start was called
    attr_accessor :current # true after missing events are processed
    attr_accessor :delay_queue # stores events while processing missing events

    def run_once
      raise 'Unsupported! Connot start a running client' if running
      self.running = true
      yield
    ensure
      self.running = false
    end

    def prepare
      self.delay_queue = []
      init_database_connection
      event_connection.start
    end

    def init_database_connection
      ActiveRecord::Base.establish_connection options[:projection_database]
    end

    def sync_projections
      server_projections.each do |projection|
        CachedProjectionRepository.ensure_solid(projection.class.name)
      end
    end

    def server_projections
      @server_projections ||= ProjectionTypeRegistry.projections.drop(WORKER_NUMBER).each_slice(WORKER_COUNT).map(&:first)
    end

    def listen_for_events
      event_queue.subscribe do |_delivery_info, properties, body|
        if current
          event_received properties, body
        else
          delay_queue << [properties, body]
        end
      end
    end

    def listen_for_replayed_events
      replay_queue.subscribe do |_delivery_info, properties, body|
        if 'replay_done' == body
          replay_done
        else
          event_received properties, body
        end
      end
    end

    def request_missing_events
      send_request_for(CachedProjectionRepository.last_ids.min || 0)
    end

    def send_projection_notification(event_id, projection, error = nil)
      message = {event: event_id, projection: projection.class.name}
      message.merge! error: "#{error.class.name}: #{error.message}", backtrace: error.backtrace if error
      server_side_events_exchange.publish message.to_json
    end

    def send_request_for(id)
      resend_request_exchange.publish id.to_s, routing_key: 'resend_request'
    end

    def replay_done
      LOGGER.debug 'All replayed events received'
      broken_projections = CachedProjectionRepository.all_broken
      LOGGER.error "These projections are still broken: #{broken_projections.join(', ')}" unless broken_projections.empty?
      replay_queue.unbind(resend_exchange)
      self.current = true
      flush_delay_queue
    end

    def flush_delay_queue
      delay_queue.each { |properties, body| event_received properties, body }
      self.delay_queue = []
    end

    def event_received(properties, body)
      RELOADER.execute_if_updated
      LOGGER.debug "Received #{properties.type} with #{body}"
      headers = properties.headers.deep_symbolize_keys!
      event = ActiveEvent::EventType.create_instance properties.type, JSON.parse(body).deep_symbolize_keys!
      process_event headers, event
    end

    def process_event(headers, event)
      server_projections.select { |p| p.evaluate headers }.each do |projection|
        begin
          ActiveRecord::Base.transaction do
            projection.invoke event, headers
          end
          send_projection_notification headers[:id], projection
        rescue => e
          send_projection_notification headers[:id], projection, e
        end
      end
    end

    def replay_queue
      @replay_queue ||= event_channel.queue('', auto_delete: true).bind(resend_exchange)
    end

    def event_queue
      @event_queue ||= event_channel.queue('', auto_delete: true).bind(event_exchange)
    end

    def event_connection
      @event_server ||= Bunny.new URI::Generic.build(options[:event_connection]).to_s
    end

    def event_channel
      @event_channel ||= event_connection.create_channel
    end

    def event_exchange
      @event_exchange ||= event_channel.fanout options[:event_exchange]
    end

    def resend_exchange
      @resend_exchange ||= event_channel.fanout "resend_#{options[:event_exchange]}"
    end

    def resend_request_exchange
      @resend_request_exchange ||= event_channel.direct "resend_request_#{options[:event_exchange]}"
    end

    def server_side_events_exchange
      @server_side_events_exchange ||= event_channel.fanout "server_side_#{options[:event_exchange]}"
    end
  end
end
