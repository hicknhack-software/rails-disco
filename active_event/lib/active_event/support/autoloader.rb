module ActiveEvent
  module Support
    module Autoloader
      def self.load_from(dirs)
        Dir[*dirs].each do |file|
          require file
        end
      end

      def self.reload_from(dirs)
        Dir[*dirs].each do |path|
          reload get_module_name(path), path
        end
      end

      def self.reload(name, path)
        const_name, namespace_name = name.to_s.split('::').reverse
        if namespace_name.nil?
          Object.send(:remove_const, const_name) if Object.const_defined?(const_name)
        else
          namespace = const_get(namespace_name)
          namespace.send(:remove_const, const_name) if namespace.const_defined?(const_name)
        end
        $LOADED_FEATURES.delete_if { |s| s.include?(path) }
        require path
      end

      private

      def self.get_module_name(path)
        segments = path.split('/')
        seg = if 1 == (segments.length - 2) - (segments.index('app') || segments.index('domain')) # no namespace
                segments.last.split('.').first
              else
                [segments[-2], segments.last.split('.').first].join('/')
              end
        seg.camelcase.to_sym
      end
    end
  end
end
