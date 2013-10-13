require 'generators/drails/use_domain_option.rb'

module Drails
  module Generators
    class ModelGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)
      argument :attributes, type: :array, default: [], banner: "field[:type] field[:type]"
      include UseDomainOption

      def create_projection_file
        generate 'drails:projection', name, use_domain_param
      end

      def create_model_file
        template use_domain('model.rb'), use_domain_class_file_path('models', "#{file_name}.rb")
      end

      def create_migration
        generate 'drails:migration', "create_#{table_name}", attributes.map { |x| "#{x.name}:#{x.type}" }.join(' '), use_domain_param
      end
    end
  end
end