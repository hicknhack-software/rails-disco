require 'rails/generators/rails/app/app_generator'
require 'yaml'

module Disco
  class AppBuilder < Rails::AppBuilder

    def gemfile
      super
      append_file 'Gemfile', "\n# Rails Disco support
gem 'rails-disco', '~> #{RailsDisco::VERSION::STRING}'\n
# Required Multithreaded Webserver
gem 'puma'\n" unless behavior == :revoke
    end

    def app
      super
      copy_file 'app/controllers/event_source_controller.rb'
      copy_file 'app/controllers/concerns/event_source.rb'
      copy_file 'app/helpers/event_source_helper.rb'
      copy_file 'app/assets/javascripts/event_source.js'
      copy_file 'app/assets/stylesheets/event_source.css'
      keep_file 'app/commands'
      keep_file 'app/events'
      keep_file 'app/projections'
      keep_file 'app/validations'

      keep_file 'domain/command_processors/domain'
      keep_file 'domain/models/domain'
      keep_file 'domain/projections/domain'
      keep_file 'domain/validations/domain'
    end

    def bin
      super
      copy_file 'bin/disco'
      chmod 'bin/disco', 0755, verbose: false
    end

    def config
      super
      inside 'config/initializers' do
        template 'create_domain.rb'
        copy_file 'build_validations_registry.rb'
        copy_file 'event_source_server.rb'
      end
    end

    def database_yml
      super
      template 'config/disco.yml'
    end

    def db
      super
      append_file 'db/seeds.rb', File.binread(File.expand_path('../templates/db/seeds.rb', __FILE__)) unless behavior == :revoke
    end
  end

  module Generators
    class AppGenerator < Rails::Generators::AppGenerator
      remove_class_option :version
      class_option :version, type: :boolean, aliases: '-v', group: :disco,
                             desc: 'Show Rails Disco version number and quit'

      remove_class_option :help
      class_option :help, type: :boolean, aliases: '-h', group: :disco,
                          desc: 'Show this help message and quit'

      # this does not seem to work !
      remove_command :apply_rails_template, :run_bundle

      def source_paths
        [File.join(Gem::Specification.find_by_name('railties').gem_dir, 'lib/rails/generators/rails/app/templates'), File.expand_path('../templates', __FILE__)]
      end

      def add_event_source_route
        return if behavior == :revoke
        route "get 'event_source/:projection/:event' => 'event_source#projected', as: 'event_source'"
      end

      def enable_rake_tasks
        return if behavior == :revoke
        content = "
require 'rails-disco/tasks'"
        inject_into_file File.join('config/application.rb'), content, after: /require 'rails\/all'/
      rescue Exception
        puts "Seems like you invoked it from an engine, so put\n
        require 'rails-disco/tasks'\n
        in your application.rb from the main application to have the rails disco rake tasks available"
      end

      def enable_concurrency
        return if behavior == :revoke
        application 'config.preload_frameworks = true'
        application 'config.allow_concurrency = true'
      rescue Exception
        puts "Seems like you invoked it from an engine, so remember to put\n
        config.preload_frameworks = true
        config.allow_concurrency = true\n
        in your application.rb from the main application"
      end

      public_task :apply_rails_template, :run_bundle

      protected

      def self.banner
        "disco new #{self.arguments.map(&:usage).join(' ')} [options]"
      end

      private

      def get_builder_class
        defined?(::AppBuilder) ? ::AppBuilder : Disco::AppBuilder
      end

      def domain_database(env, indent_level)
        config = YAML.load(File.read('config/database.yml'))[env.to_s]
        config['database'].sub!(/.*#{env}/, '\0_domain')
        indent( ({'domain_database' => config}.to_yaml(indentation: 2))[4..-1], indent_level)
      end

      # copied namespace support from NamedBase
      def module_namespacing(&block)
        content = capture(&block)
        content = wrap_with_namespace(content) if namespace
        concat(content)
      end

      def indent(content, multiplier = 2)
        spaces = ' ' * multiplier
        content.each_line.map {|line| line.blank? ? line : "#{spaces}#{line}" }.join
      end

      def wrap_with_namespace(content)
        content = indent(content).chomp
        "module #{namespace.name}\n#{content}\nend\n"
      end

      def namespace
        Rails::Generators.namespace
      end
    end
  end
end
