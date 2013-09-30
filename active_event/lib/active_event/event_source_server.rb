require 'reloader/sse'
require 'bunny'
module ActiveEvent
  module EventSourceServer
    def subscribe_to(queue, &block)
      queue.subscribe(block: true, &block)
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