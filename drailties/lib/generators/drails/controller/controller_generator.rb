require 'rails/generators/rails/scaffold_controller/scaffold_controller_generator'
module Drails
  module Generators
    class ControllerGenerator < Rails::Generators::ScaffoldControllerGenerator
      source_root File.expand_path('../templates', __FILE__)
      hide!

      private
      def params_string
        attributes.map{|x| "#{x.name}: params[:#{singular_table_name}][:#{x.name}]" }.join(', ')
      end
    end
  end
end