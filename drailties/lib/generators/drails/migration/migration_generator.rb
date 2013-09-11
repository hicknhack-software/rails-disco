require 'rails/generators/active_record/migration/migration_generator'
module Drails
  module Generators
    class MigrationGenerator < ActiveRecord::Generators::MigrationGenerator
      source_root File.expand_path('../templates', __FILE__)
      hide!
      remove_argument :attibutes
      argument :use_domain, type: :string, default: 'false'
      argument :attributes, type: :array, default: [], banner: "field[:type] field[:type]"

      def create_migration_file
        set_local_assigns!
        validate_file_name!
        migration_template @migration_template, "db/#{migration_dir}/#{file_name}.rb"
      end

      private
      def migration_dir
        if (/^(true|t|yes|y|1)$/i).match(use_domain)
          'migrate_domain'
        else
          'migrate'
        end
      end
    end
  end
end