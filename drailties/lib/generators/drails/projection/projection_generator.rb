module Drails
  module Generators
    class ProjectionGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)
      argument :use_domain, type: :string, default: 'false'
      argument :events, type: :array, default: [], banner: "event event"

      def create_projection_file
        if domain?
          template 'domain_projection.rb', File.join('domain', 'projections', domain_ns, "#{file_name}_projection.rb")
        else
          template 'projection.rb', File.join('app', 'projections', class_path, "#{file_name}_projection.rb")
        end
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