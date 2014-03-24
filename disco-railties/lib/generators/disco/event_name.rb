require 'active_support/concern'

module Disco
  module Generators
    module EventName
      extend ActiveSupport::Concern

      included do
        class_option :event, type: :string, default: nil, desc: 'class_name of the event (defaults to NAME)'
        class_option :skip_event, type: :boolean, default: false, desc: 'skip event generation'
      end

      def initialize(args, *options)
        super
        assign_event_name!(event_name)
      end      

      protected

      attr_reader :event_file_name
      attr_reader :event_class_path

      def skip_event?
        options[:skip_event]
      end

      def event_name
        options[:event] || name
      end

      def event_class_name
        (event_class_path + [event_file_name]).map!{ |m| m.camelize }.join('::')
      end

      def event_file_path
        @event_file_path ||= (event_class_path + [event_file_name]).join('/')
      end

      def event_domain_class_path
        @event_domain_class_path ||= class_path_domain event_class_path
      end

      private

      def assign_event_name!(event_name)
        @event_class_path = event_name.include?('/') ? event_name.split('/') : event_name.split('::')
        @event_class_path.map! &:underscore
        @event_file_name = @event_class_path.pop
      end
    end
  end
end
