require 'rails/generators/active_record/migration/migration_generator'
require 'generators/drails/use_domain_option.rb'

module Drails
  module Generators
    class MigrationGenerator < ActiveRecord::Generators::MigrationGenerator
      source_root File.expand_path('../templates', __FILE__)
      include UseDomainOption

      def create_migration_file
        set_local_assigns!
        validate_file_name!
        migration_template @migration_template, "db/#{migration_dir}/#{file_name}.rb"
      end

      private

      def migration_dir
        if use_domain?
          'migrate_domain'
        else
          'migrate'
        end
      end
    end
  end
end
