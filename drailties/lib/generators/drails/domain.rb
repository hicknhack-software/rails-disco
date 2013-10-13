require 'active_support/concern'

module Drails
  module Generators
    module Domain
      extend ActiveSupport::Concern

      def domain_class_path
        @domain_calss_path ||= class_path_domain class_path
      end

      protected

      def class_path_domain(class_path)
        namespace_path = Array.new class_path
        if namespace_path.empty?
          namespace_path[0] = 'domain'
        else
          namespace_path[-1] += '_domain'
        end
        namespace_path
      end
    end
  end
end