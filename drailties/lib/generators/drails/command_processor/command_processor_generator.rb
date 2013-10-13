require 'generators/drails/domain.rb'

module Drails
  module Generators
    class CommandProcessorGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)
      include Domain
      hide!

      def create_command_processor_file
        template 'command_processor.rb', File.join('domain/command_processors', domain_class_path, "#{file_name}_processor.rb")
      end
    end
  end
end