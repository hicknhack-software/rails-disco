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

      def add_drails_to_gemfile
        gem "rails-disco"
      end
    end
  end
end