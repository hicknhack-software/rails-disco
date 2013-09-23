require 'singleton'
require 'bunny'
require 'thread'
module ActiveEvent
  class ReplayServer
    include Singleton

    def self.start(options, id)
      instance.options = options
      instance.start id
    end

    def self.update(id)
      instance.queue << id
    end

    def start(id)
      event_connection.start
      @last_id = id
      start_republishing
      send_done_message
    end

    def queue
      @queue ||= Queue.new
    end

    def send_done_message
      resend_exchange.publish 'replay_done'
    end

    def start_republishing
      loop do
        @events = EventRepository.after_id(@last_id).to_a
        return if @events.empty?
        republish_events
      end
    end

    def republish_events
      while has_next_event?
        return if new_id?
        republish next_event
        Thread.pass
      end
    end

    def new_id?
      unless queue.empty?
        new_id = queue.pop
        if new_id < @last_id
          @last_id = new_id
          return true
        end
      end
      false
    end

    def republish(e)
      type = e.event
      body = e.data.to_json
      resend_exchange.publish body, {type: type, headers: {store_id: e.id, replayed: true}}
      puts "Republished #{type} with #{body}"
    end

    def next_event
      e = @events.shift
      @last_id = e.id
      e
    end

    def has_next_event?
      @events.length > 0
    end

    def event_connection
      @event_server ||= Bunny.new URI::Generic.build(options[:event_connection]).to_s
    end

    def event_channel
      @event_channel ||= event_connection.create_channel
    end

    def resend_exchange
      @resend_exchange ||= event_channel.fanout "resend_#{options[:event_exchange]}"
    end

    def options
      @options
    end

    attr_writer :options
  end
end