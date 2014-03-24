require 'generators/disco/processor_name.rb'
require 'generators/disco/domain.rb'

module Disco
  module Generators
    class ScaffoldGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)
      argument :attributes, type: :array, default: [], banner: 'field[:type] field[:type]'
      include ProcessorName
      include Domain

      hook_for :model, in: :disco, require: true

      hook_for :command, in: :disco, require: true do |hook|
        raise 'do not use id as scaffolding attribute! This is reserved for the model id' if attributes_names.include? 'id'
        %w(create update delete).each do |action|
          args = [(class_path + ["#{action}_#{file_name}"]) * '/']
          args << 'id' unless action == 'create'
          args += attributes_names unless action == 'delete'
          opts = ["--event=#{(class_path + ["#{action}d_#{file_name}"]) * '/'}"]
          opts << "--processor=#{processor_name}" unless skip_processor?
          opts << "--model_name=#{class_name}"
          opts << '--unique_id' if action == 'create'
          opts << '--persisted' if action == 'update'
          opts << '--skip_model' if action == 'delete'
          invoke hook, args, opts
          add_to_projections(action)
        end
      end

      def add_routes
        routing_code = ''
        class_path.each_with_index do |namespace, index|
          add_line_with_indent routing_code, (index + 1), "namespace :#{namespace} do"
        end
        add_line_with_indent routing_code, (class_path.length + 1), "resources :#{plural_name}"
        class_path.each_with_index do |_, index|
          add_line_with_indent routing_code, (class_path.length - index), 'end'
        end
        route routing_code[2..-1]
      end

      hook_for :scaffold_controller, in: :disco, require: true do |hook|
        invoke hook
        add_event_stream_to_views
      end

      def copy_event_stream_client
        # ensure if app was created before this was default
        copy_file '_eventstream.js.erb', 'app/views/application/eventstream/_eventstream.js.erb', verbose: false, skip: true
      end

      protected

      def add_event_stream_to_views
        return if behavior == :revoke
        include_text = '<%= javascript_tag render partial: \'application/eventstream/eventstream\', formats: [:js], locals: {event_id: @event_id} %>'
        prepend_to_file File.join('app/views', class_path, plural_file_name, 'index.html.erb'), include_text
        prepend_to_file File.join('app/views', class_path, plural_file_name, 'show.html.erb'), include_text
      end

      def add_to_projections(action)
        return if behavior == :revoke
        event_func = (class_path + ["#{action}d_#{file_name}_event"]) * '__'
        content = "

  def #{event_func}(event)
    #{method_bodies[action.to_sym]}
  end"
        indent(content) if namespaced?
        inject_into_file File.join('app/projections', class_path, "#{plural_file_name}_projection.rb"), content, after: /(\s)*include(\s)*ActiveProjection::ProjectionType/
      end

      def method_bodies
        @method_bodies ||= {
            create: "#{class_name}.create! event.to_hash",
            update: "#{class_name}.find(event.id).update! event.values",
            delete: "#{class_name}.find(event.id).destroy!",
        }
      end

      def add_line_with_indent(target, indent, str)
        target << "#{'  ' * indent}#{str}\n"
      end
    end
  end
end
