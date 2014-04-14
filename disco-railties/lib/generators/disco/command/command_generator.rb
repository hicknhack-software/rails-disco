require 'generators/disco/processor_name.rb'
require 'generators/disco/event_name.rb'
require 'generators/disco/domain.rb'

module Disco
  module Generators
    class CommandGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)
      argument :attributes, type: :array, default: [], banner: '[attribute] [attribute]'
      class_option :unique_id, type: :boolean, default: false, desc: 'Create a unique id when processing the command'
      class_option :skip_model, type: :boolean, default: false, desc: 'Skip active model from the command'
      class_option :model_name, type: :string, desc: 'Name of the active model behind the command'
      class_option :persisted, type: :boolean, default: false, desc: 'Does the command update an existing model'
      include ProcessorName
      include EventName
      include Domain

      def create_command_file
        template 'command.rb.erb', File.join('app/commands', class_path, "#{file_name}_command.rb")
      end

      def create_related_event_file
        return if skip_event?
        template 'event.rb.erb', File.join('app/events', event_class_path, "#{event_file_name}_event.rb")
      end

      hook_for :command_processor, require: true do |hook|
        unless skip_processor?
          invoke hook, [processor_file_path], %w(-s --skip-namespace)
          add_to_command_processor
        end
      end

      private

      def add_to_command_processor
        return if skip_processor? || (behavior == :revoke)
        extra, merge = '', ''
        if unique_id?
          extra = "\n        id = ActiveDomain::UniqueCommandIdRepository.new_for command.class.name"
          merge = '.merge(id: id)'
        end
        content = <<-EOF

    process #{class_name}Command do |command|
      command.is_valid_do do#{extra}
        event #{event_class_name}Event.new command.to_hash#{merge}
      end
    end
        EOF
        file = File.join('domain/command_processors', processor_domain_class_path, "#{processor_file_name}_processor.rb")
        inject_into_file file, content, after: /\s*include\s+ActiveDomain::CommandProcessor/
      end

      protected

      def unique_id?
        options[:unique_id]
      end

      def skip_model?
        options[:skip_model]
      end

      def model_name
        options[:model_name]
      end

      def persisted?
        options[:persisted]
      end

      def event_attributes_names
        @event_attribute_names ||= if unique_id?
                                     attributes_names.dup.unshift 'id'
                                   else
                                     attributes_names
                                   end
      end

      private

      # allow this generator to be called multiple times
      def invoke_command(command, *args) #:nodoc:
        command.run(self, *args)
      end
    end
  end
end
