require 'generators/drails/processor_name.rb'
require 'generators/drails/domain.rb'

module Drails
  module Generators
    class ScaffoldGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)
      argument :attributes, type: :array, default: [], banner: "field[:type] field[:type]"
      include ProcessorName
      include Domain

      hook_for :model, in: :drails, require: true

      hook_for :command, in: :drails, require: true do |hook|
        %w(create update delete).each do |action|
          args = [(class_path + ["#{action}_#{file_name}"]) * '/']
          args += attributes_names unless action == 'delete'
          opts = ["--event=#{(class_path + ["#{action}d_#{file_name}"]) * '/'}"]
          opts << "--processor=#{processor_name}" unless skip_processor?
          opts << '--skip_model' if action == 'delete'
          invoke hook, args, opts
          add_to_projections(action)
        end
        add_to_command_processor
      end

      def add_routes
        routing_code = ''
        class_path.each_with_index do |ns, i|
          add_line_with_indent routing_code, (i + 1), "namespace :#{ns} do"
        end
        add_line_with_indent routing_code, (class_path.length + 1), "resources :#{plural_name}"
        class_path.each_with_index do |ns, i|
          add_line_with_indent routing_code, (class_path.length - i), "end"
        end
        route routing_code[2..-1]
      end

      hook_for :scaffold_controller, in: :drails, require: true do |hook|
        invoke hook
        add_event_stream_client_to_views
      end

      def copy_event_stream_client
        # ensure if app was created before this was default
        copy_file '_eventstream.js.erb', 'app/views/application/eventstream/_eventstream.js.erb', verbose: false, skip: true
      end

      protected

      def add_event_stream_client_to_views
        include_text = '<%= javascript_tag render partial: \'eventstream/eventstream\', formats: [:js], locals: {event_id: @event_id} %>'
        prepend_to_file File.join('app/views', class_path, plural_file_name, 'index.html.erb'), include_text
        prepend_to_file File.join('app/views', class_path, plural_file_name, 'show.html.erb'), include_text
      end

      def add_to_command_processor
        content = "\n       command.id = ActiveDomain::UniqueCommandIdRepository.new_for command.class.name"
        insert_into_file File.join('domain/command_processors', domain_class_path, "#{processor_file_name}_processor.rb"), content, after: /(\s)*process(\s)*(.)*CreateCommand(.)*/
      end

      def add_to_projections(action)
        event_func = (class_path + ["#{file_name}_#{action}d_event"]) * '__'
        content = "

  def #{event_func}(event)
    #{method_bodies[action]}
  end"
        indent(content) if namespaced?
        inject_into_file File.join('app/projections', class_path, "#{plural_file_name}_projection.rb"), content, after: /(\s)*include(\s)*ActiveProjection::ProjectionType/
      end

      def method_bodies
        {
            'create' => "#{class_name}.create! event.values.merge(id: event.id)",
            'update' => "#{class_name}.find(event.id).update! event.values",
            'delete' => "#{class_name}.find(event.id).destroy!",
        }
      end

      def add_line_with_indent(target, indent, str)
        target << "#{"  " * indent}#{str}\n"
      end
    end
  end
end
