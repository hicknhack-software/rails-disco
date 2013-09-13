module Drails
  module Generators
    class ProjectionGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)
      argument :use_domain, type: :string, default: 'false'
      argument :events, type: :array, default: [], banner: "event event"

      def create_projection_file
        if domain?
          template 'domain_projection.rb', File.join('domain', 'projections', domain_ns, "#{plural_file_name}_projection.rb")
        else
          template 'projection.rb', File.join('app', 'projections', class_path, "#{plural_file_name}_projection.rb")
        end
      end

      def create_test_files
        if domain?
          template 'domain_projection_test.rb', File.join("test/projections", class_path, "#{plural_file_name}_projection_test.rb")
        else
          template 'projection_test.rb', File.join("test/projections", class_path, "#{plural_file_name}_projection_test.rb")
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