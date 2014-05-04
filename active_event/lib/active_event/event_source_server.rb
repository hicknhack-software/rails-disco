require 'singleton'
require 'bunny'

module ActiveEvent
  class ProjectionException < StandardError
    # prevent better errors from tracing this exception
    def __better_errors_bindings_stack; [] end
  end

  class EventSourceServer
    include Singleton

    class << self
      def after_event_projection(event_id, projection, &block)
        instance.after_event_projection(event_id, projection, &block)
      end

      def projection_status(projection)
        instance.projection_status(projection)
      end
    end

    def after_event_projection(event_id, projection)
      mutex.synchronize do
        projection_status = status[projection]
        if projection_status.event_id < event_id
          cv = ConditionVariable.new
          begin
            projection_status.waiters[event_id] << cv
            cv.wait(mutex)
          ensure
            projection_status.waiters[event_id].delete cv
          end
        end
        raise ProjectionException, projection_status.error, projection_status.backtrace if projection_status.error
      end
      yield
    end

    def projection_status(projection)
      mutex.synchronize do
        projection_status = status[projection]
        raise ProjectionException, projection_status.error, projection_status.backtrace if projection_status.error
      end
    end

    private

    class Status
      attr_accessor :event_id, :waiters, :error, :backtrace

      def initialize
        self.event_id = 0
        self.waiters = Hash.new { |h,k| h[k] = [] }
      end
    end

    attr_accessor :mutex # synchronize access to status
    attr_accessor :status # status of all projections received so far

    def initialize
      self.mutex = Mutex.new
      self.status = Hash.new { |h,k| h[k] = Status.new }
      event_connection.start
      event_queue.subscribe do |delivery_info, properties, body|
        process_projection JSON.parse(body).symbolize_keys!
      end
    end

    def process_projection(data)
      mutex.synchronize do
        projection_status = status[data[:projection]]
        projection_status.event_id = data[:event]
        projection_status.error = data[:error] if data.key? :error
        projection_status.backtrace = data[:backtrace] if data.key? :backtrace
        projection_status.waiters.delete(data[:event]).to_a.each { |cv| cv.signal }
      end
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
      @@event_exchange ||= event_channel.fanout "server_side_#{options[:event_exchange]}"
    end

    def default_options
      {
          event_connection: {
              scheme: 'amqp',
              userinfo: nil,
              host: '127.0.0.1',
              port: 9797,
          },
          event_exchange: 'events'
      }
    end

    def parse_options(args)
      options = default_options
      options.merge! YAML.load_file(config_file)[env].deep_symbolize_keys! unless config_file.blank?
    end

    def config_file
      File.expand_path('config/disco.yml', Rails.root)
    end

    def options
      @options ||= parse_options(ARGV)
    end

    def env
      @env = ENV['PROJECTION_ENV'] || ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
    end

    attr_writer :options
  end
end
