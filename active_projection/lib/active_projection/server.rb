require 'active_record'

module ActiveProjection
  class Server

    def self.run(options = nil)
      self.new(options).run
    end

    def initialize(new_options = nil)
      self.options = new_options.deep_symbolize_keys! unless new_options.nil?
    end

    def run
      ActiveRecord::Base.establish_connection options[:projection_database]
      EventClient.start options
    end

    def env
      @env = ENV['PROJECTION_ENV'] || ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
    end

    def options
      @options ||= parse_options(ARGV)
    end

    cattr_accessor :base_path
    cattr_accessor :config_file
    cattr_accessor :rails_config_file

    def config_file
      self.class.config_file ||= File.expand_path('config/disco.yml', base_path)
    end

    def rails_config_file
      self.class.rails_config_file ||= File.expand_path('config/database.yml', base_path)
    end

    private

    attr_writer :options
    attr_writer :domain

    def default_options
      {
          projection_database: {
              adapter: 'sqlite3',
              database: File.expand_path('db/production.sqlite3', base_path)
          },
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
      options[:projection_database] = YAML.load_file(rails_config_file)[env].deep_symbolize_keys! unless rails_config_file.blank?
      options
    end
  end
end
