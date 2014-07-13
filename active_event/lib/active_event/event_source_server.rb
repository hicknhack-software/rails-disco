require 'singleton'
require 'bunny'

module ActiveEvent
  class ProjectionException < StandardError
    # prevent better errors from tracing this exception
    def __better_errors_bindings_stack
      []
    end
  end

  class EventSourceServer
    include Singleton

    class << self
      def wait_for_event_projection(event_id, projection, options = {})
        instance.wait_for_event_projection(event_id, projection, options)
      end

      def fail_on_projection_error(projection)
        instance.fail_on_projection_error(projection)
      end
    end

    def wait_for_event_projection(event_id, projection, options = {})
      mutex.synchronize do
        projection_status = status[projection]
        projection_status.fail_on_error # projection will not continue if error occurred
        projection_status.waiter(event_id).wait(mutex, options[:timeout])
        projection_status.fail_on_error
      end
    end

    def fail_on_projection_error(projection)
      mutex.synchronize do
        projection_status = status[projection]
        projection_status.fail_on_error
      end
    end

    private

    class Status
      module UnconditionalVariable
        def self.wait(_mutex, _timeout = 0)
          nil
        end
      end

      @event_id = 0
      @error = nil
      @backtrace = nil

      def initialize
        @waiters = {}
      end

      def waiter(event)
        if event > @event_id
          @waiters[event] ||= ConditionVariable.new
        else
          UnconditionalVariable
        end
      end

      def set_error(error, backtrace)
        @error, @backtrace = error, backtrace if error || backtrace
      end

      def event=(event)
        @event_id = event
        cvs = []
        @waiters.delete_if { |event_id, cv| (event_id <= event) && (cvs << cv) }
        cvs.map &:broadcast
      end

      def fail_on_error
        fail ProjectionException, @error, @backtrace if @error
      end
    end

    attr_accessor :mutex # synchronize access to status
    attr_accessor :status # status of all projections received so far

    def initialize
      self.mutex = Mutex.new
      self.status = Hash.new { |h, k| h[k] = Status.new }
      event_connection.start
      event_queue.subscribe do |_delivery_info, _properties, body|
        process_projection JSON.parse(body).symbolize_keys!
      end
    end

    def process_projection(data)
      mutex.synchronize do
        projection_status = status[data[:projection]]
        projection_status.set_error data[:error], data[:backtrace]
        projection_status.event = data[:event]
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
        event_exchange: 'events',
      }
    end

    def parse_options(_args)
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
