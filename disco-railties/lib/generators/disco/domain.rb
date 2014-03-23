require 'active_support/concern'

module Disco
  module Generators
    module Domain
      extend ActiveSupport::Concern

      def domain_class_path
        @domain_calss_path ||= class_path_domain class_path
      end

      protected

      def class_path_domain(class_path)
        (Array.new class_path).unshift 'domain'
      end
    end
  end
end
