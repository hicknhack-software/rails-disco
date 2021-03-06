require 'generators/disco/use_domain_option.rb'

module Disco
  module Generators
    class ModelGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)
      argument :attributes, type: :array, default: [], banner: 'field[:type] field[:type]'
      include UseDomainOption

      hook_for :projection, require: true do |hook|
        invoke hook, [name]
      end

      def create_model_file
        template use_domain('model.rb.erb'), use_domain_class_file_path('models', "#{file_name}.rb")
      end

      hook_for :migration, require: true do |hook|
        invoke hook, ["create_#{table_name}", *attributes]
      end

      hook_for :test_framework

      private

      # do not parse - keep attributes for forwarding to migration
      def parse_attributes!
      end
    end
  end
end
