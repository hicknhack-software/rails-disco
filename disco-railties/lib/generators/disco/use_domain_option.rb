require 'active_support/concern'
require 'generators/disco/domain.rb'

module Disco
  module Generators
    module UseDomainOption
      extend ActiveSupport::Concern

      include Domain

      included do
        class_option :domain, type: :boolean, default: false, desc: 'generate for the domain'
      end

      protected

      def use_domain?
        options[:domain]
      end

      def use_domain(file_name)
        if use_domain?
          "domain_#{file_name}"
        else
          file_name
        end
      end

      def use_domain_class_path
        if use_domain?
          domain_class_path
        else
          class_path
        end
      end

      def use_domain_base_path
        if use_domain?
          'domain'
        else
          'app'
        end
      end

      def use_domain_class_file_path(type, file_name)
        File.join use_domain_base_path, type, use_domain_class_path, file_name
      end

      def use_domain_param
        '--domain' if use_domain?
      end
    end
  end
end
