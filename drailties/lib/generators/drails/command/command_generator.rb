module Drails
  module Generators
    class CommandGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)
      argument :attributes, type: :array, default: [], banner: "attribute attribute"

      def create_command_file
        template 'command.rb', File.join('app/commands', class_path, "#{file_name}_command.rb")
      end

      def create_related_event_file
        template 'event.rb', File.join('app/events', class_path, "#{file_name}_event.rb")
      end

      def create_command_processor
        generate 'drails:command_processor', processor_file_name, '-s'
      end

      def add_to_command_processor
        content = "

    process #{class_name}Command do |command|
      command.is_valid_do { event #{class_name}Event.new command.to_hash }
    end"
        inject_into_file File.join('domain/command_processors', domain_ns, "#{processor_file_name}_processor.rb"), content, after: /(\s)*include(\s)*ActiveDomain::CommandProcessor/
      end

      private
      def processor_file_name
        file_name.split('_').first
      end

      def domain_ns
        namespace_path = Array.new class_path
        if namespace_path.empty?
          namespace_path[0] = 'domain'
        else
          namespace_path[-1] += '_domain'
        end
        namespace_path
      end
    end
  end
end