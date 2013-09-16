require 'singleton'
require 'drb/drb'

module ActiveEvent
  module Domain
    extend ActiveSupport::Concern

    included do
      include Singleton # singleton is not a concern - include directly into class
    end

    def initialize(*args)
      super
      # DRb.start_service # should not be necessary
      self.server = DRbObject.new_with_uri self.class.server_uri
    end

    def run_command(command)
      server.run_command command
    end

    private

    attr_accessor :server

    module ClassMethods
      def run_command(command)
        self.instance.run_command command
      end

      attr_accessor :server_uri

      def self.extended(base)
        base.server_uri = 'druby://127.0.0.1:8787'
      end

      def set_config(protocol = 'druby', host = 'localhost', port = 8787)
        self.server_uri = "#{protocol}://#{host}:#{port}"
      end
    end
  end
end