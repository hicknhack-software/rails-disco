module Drails
  module Generators
    class CommandProcessorGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)
      hide!

      def create_command_processor_file
        template 'command_processor.rb', File.join('domain/command_processors', domain_ns, "#{file_name}_processor.rb")
      end

      private
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