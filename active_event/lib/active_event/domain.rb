require 'singleton'
require 'drb/drb'

module ActiveEvent
  class DomainExceptionCapture < StandardError
  end

  class DomainException < StandardError
    # prevent better errors from tracing this exception
    def __better_errors_bindings_stack
      []
    end
  end

  module Domain
    extend ActiveSupport::Concern

    included do
      include Singleton # singleton is not a concern - include directly into class
    end

    def initialize(*args)
      super
      self.server = DRbObject.new_with_uri drb_server_uri
    end

    def run_command(command)
      command.valid? && server.run_command(command)
    rescue DomainExceptionCapture => e
      message, backtrace = JSON.parse(e.message)
      raise DomainException, message, backtrace
    end

    private

    attr_accessor :server

    def drb_server_uri
      self.class.drb_server_uri || URI::Generic.build(options[:drb_server]).to_s
    end

    def options
      @options ||= parse_options
    end

    def config_file
      self.class.config_file || File.join(Rails.root, 'config', 'disco.yml')
    end

    def default_options
      {
          drb_server: {
              scheme: 'druby',
              hostname: '127.0.0.1',
              port: 8787,
          },
      }
    end

    def parse_options
      options = default_options
      options.merge! YAML.load_file(config_file)[Rails.env].deep_symbolize_keys! unless config_file.blank?
    end

    module ClassMethods
      def run_command(command)
        instance.run_command command
      end

      attr_accessor :drb_server_uri
      attr_accessor :config_file

      def set_config(protocol = 'druby', host = 'localhost', port = 8787)
        self.drb_server_uri = "#{protocol}://#{host}:#{port}"
      end
    end
  end
end
