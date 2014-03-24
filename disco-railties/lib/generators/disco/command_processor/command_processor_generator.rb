require 'generators/disco/domain.rb'

module Disco
  module Generators
    class CommandProcessorGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)
      include Domain
      hide!

      def create_command_processor_file
        template 'command_processor.rb.erb', File.join('domain/command_processors', domain_class_path, "#{file_name}_processor.rb")
      end

      private

      # allow this generator to be called multiple times
      def invoke_command(command, *args) #:nodoc:
        command.run(self, *args)
      end
    end
  end
end
