require 'active_record'
require 'drb/drb'

module ActiveDomain
  class Server
    def self.run(options = nil)
      new(options).run
    end

    def initialize(new_options = nil)
      self.options = new_options.deep_symbolize_keys! unless new_options.nil?
    end

    def run
      ActiveRecord::Base.establish_connection options[:domain_database]
      ActiveEvent::EventServer.start options
      drb_uri = URI::Generic.build(options[:drb_server]).to_s
      DRb.start_service(drb_uri, domain, options.fetch(:drb_config, {}))
      DRb.thread.join
    rescue Interrupt
      LOGGER.info 'Catching Interrupt'
    rescue => e
      LOGGER.error e.message
      LOGGER.error e.backtrace.join("\n")
      raise e
    end

    def env
      @env = ENV['DOMAIN_ENV'] || ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
    end

    def options
      @options ||= parse_options(ARGV)
    end

    def domain
      @domain ||= ActiveDomain::CommandRoutes.new
    end

    cattr_accessor :base_path
    cattr_accessor :config_file

    def config_file
      self.class.config_file || File.expand_path('config/disco.yml', base_path)
    end

    private

    attr_writer :options
    attr_writer :domain

    def default_options
      {
        drb_server: {
          scheme: 'druby',
          hostname: '127.0.0.1',
          port: 8787,
        },
        drb_config: {
          verbose: true,
          },
        domain_database: {
          adapter: 'sqlite3',
          database: File.expand_path('db/domain.sqlite3', base_path),
          },
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
  end
end
