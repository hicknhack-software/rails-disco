module Drails
  module Generators
    class AppGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)
      argument :name, type: :string, default: '', banner: "[name]"

      def copy_config
        copy_file 'disco.yml', File.join('config', 'disco.yml')
      end

      def create_domain_initializer
        template 'create_domain.rb', File.join('config', 'initializers', 'create_domain.rb')
      end

      def copy_validation_registry_initializer
        copy_file 'build_validations_registry.rb', File.join('config', 'initializers', 'build_validations_registry.rb')
      end

      def copy_sse_controller
        copy_file 'event_source_controller.rb', File.join('app', 'controllers', 'event_source_controller.rb')
      end

      def add_sse_route
        route "get 'event_stream' => 'event_source#stream'"
      end

      def add_drails_to_gemfile
        gem "rails-disco"
      end

      def enable_rake_tasks
        content = "
require 'rails-disco/tasks'"
        inject_into_file File.join('config/application.rb'), content, after: /require 'rails\/all'/
      rescue Exception
        puts "Seems like you invoked it from an engine, so put\n
        require 'rails-disco/tasks'\n
        in your application.rb from the main application to have the rails disco rake tasks available"
      end

      def enable_concurrency
        application 'config.preload_frameworks = true'
        application 'config.allow_concurrency = true'
      rescue Exception
        puts "Seems like you invoked it from an engine, so remember to put\n
        config.preload_frameworks = true
        config.allow_concurrency = true\n
        in your application.rb from the main application"
      end
    end
  end
end