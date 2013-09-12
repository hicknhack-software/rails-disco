module Drails
  module Generators
    class ModelGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)
      argument :use_domain, type: :string, default: 'false'
      argument :attributes, type: :array, default: [], banner: "field[:type] field[:type]"

      def create_projection_file
        if domain?
          generate 'drails:projection', name, 'true'
        else
          generate 'drails:projection', name
        end
      end

      def create_model_file
        if domain?
          template 'domain_model.rb', File.join('domain', 'models', domain_ns, "#{file_name}.rb")
        else
          template 'model.rb', File.join('app', 'models', class_path, "#{file_name}.rb")
        end
      end

      def create_migration
        generate 'drails:migration', "create_#{table_name}", use_domain, attributes.map { |x| "#{x.name}:#{x.type}" }.join(' ')
      end

      private
      def domain?
        @domain ||= !!(/^(true|t|yes|y|1)$/i).match(use_domain)
      end

      def domain_ns
        namespace_path = Array.new class_path
        if namespace_path.empty?
          namespace_path[0] = 'domain'
        else
          namespace_path[-1] += '_domain'
        end
      end
    end
  end
end