require 'active_support/concern'

module Drails
  module Generators
    module ProcessorName
      extend ActiveSupport::Concern

      included do
        class_option :processor, type: :string, default: nil, desc: "class_name of the command processor (defaults to NAME)"
        class_option :skip_processor, type: :boolean, default: false, desc: "Skip command processor generation"
      end

      def initialize(args, *options)
        super
        assign_processor_names!(processor_name)
      end      

      protected

      attr_reader :processor_file_name
      attr_reader :processor_class_path

      def skip_processor?
        options[:skip_processor]
      end

      def processor_name
        options[:processor] || name
      end

      def processor_file_path
        @processor_file_path ||= (processor_class_path + [processor_file_name]).join('/')
      end

      def processor_domain_class_path
        @processor_domain_class_path ||= class_path_domain processor_class_path
      end

      private

      def assign_processor_names!(processor_name)
        @processor_class_path = processor_name.include?('/') ? processor_name.split('/') : processor_name.split('::')
        @processor_class_path.map! &:underscore
        @processor_file_name = @processor_class_path.pop
      end
    end
  end
end