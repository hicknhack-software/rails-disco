require 'generators/drails/processor_name.rb'
require 'generators/drails/event_name.rb'
require 'generators/drails/domain.rb'

module Drails
  module Generators
    class CommandGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)
      argument :attributes, type: :array, default: [], banner: 'attribute attribute'
      class_option :skip_model, type: :boolean, default: false, desc: 'Skip command as form model'
      include ProcessorName
      include EventName
      include Domain

      def create_command_file
        template 'command.rb', File.join('app/commands', class_path, "#{file_name}_command.rb")
      end

      def create_related_event_file
        return if skip_event?
        template 'event.rb', File.join('app/events', event_class_path, "#{event_file_name}_event.rb")
      end

      hook_for :command_processor, require: true do |hook|
        unless skip_processor?
          invoke hook, [processor_file_path], ['-s', '--skip-namespace']
          add_to_command_processor
        end
      end

      private

      def add_to_command_processor
        return if skip_processor?
        content = "

    process #{class_name}Command do |command|
      command.is_valid_do { event #{event_class_name}Event.new command.to_hash }
    end"
        file = File.join('domain/command_processors', processor_domain_class_path, "#{processor_file_name}_processor.rb")
        inject_into_file file, content, after: /(\s)*include(\s)*ActiveDomain::CommandProcessor/
      end

      protected

      def skip_model?
        options[:skip_model]
      end

      private

      # allow this generator to be called multiple times
      def invoke_command(command, *args) #:nodoc:
        command.run(self, *args)
      end
    end
  end
end
