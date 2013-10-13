require 'generators/drails/processor_name.rb'
require 'generators/drails/domain.rb'

module Drails
  module Generators
    class ScaffoldGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)
      argument :attributes, type: :array, default: [], banner: "field[:type] field[:type]"
      include ProcessorName
      include Domain

      def create_models
        generate 'drails:model', name, attr_string
      end

      def create_commands
        %w(create update delete).each do |action|
          attr_arg = attributes_names.join(' ') unless action == 'delete'
          command = (class_path + ["#{action}_#{file_name}"]) * '/'
          event_arg = "--event=" + (class_path + ["#{action}d_#{file_name}"]) * '/'
          processor_arg = "--processor=#{processor_name}"
          processor_arg = "--skip-processor" if skip_processor?
          generate 'drails:command', command, attr_arg, processor_arg, event_arg
          add_to_projections(action)
        end
      end

      def add_to_command_processor
        content = "
      command.id = ActiveDomain::UniqueCommandIdRepository.new_for command.class.name"
        inject_into_file File.join('domain/command_processors', domain_class_path, "#{processor_file_name}_processor.rb"), content, after: /(\s)*process(\s)*(.)*CreateCommand(.)*/
      end

      def add_route
        route "resources :#{plural_name}"
      end

      def create_controller
        generate 'drails:controller', name, attr_string
      end

      def copy_event_stream_client
        copy_file '_eventstream.js.erb', File.join('app/views', class_path, plural_file_name, '_eventstream.js.erb')
      end

      def add_event_stream_client_to_views
        include_text = '<%= javascript_tag render partial: \'eventstream\', formats: [:js], locals: {event_id: @event_id} %>'
        prepend_to_file File.join('app/views', class_path, plural_file_name, 'index.html.erb'), include_text
        prepend_to_file File.join('app/views', class_path, plural_file_name, 'show.html.erb'), include_text
      end

      private

      def attr_string
        @attr_string ||= attributes.map { |x| "#{x.name}:#{x.type}" }.join(' ')
      end

      def add_to_projections(action)
        event_func = (class_path + ["#{action}d_#{file_name}_event"]) * '__'
        content = "

    def #{event_func}(event)
      #{method_bodies[action]}
    end"
        inject_into_file File.join('app/projections', class_path, "#{plural_file_name}_projection.rb"), content, after: /(\s)*include(\s)*ActiveProjection::ProjectionType/
      end

      def method_bodies
        {
            'create' => "#{class_name}.create! event.values.merge(id: event.id)",
            'update' => "#{class_name}.find(event.id).update! event.values",
            'delete' => "#{class_name}.find(event.id).destroy!",
        }
      end
    end
  end
end