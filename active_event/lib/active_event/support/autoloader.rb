module ActiveEvent::Support
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

    def self.reload(module_name, path)
      Object.send(:remove_const, module_name) if Object.const_defined?(module_name)
      $".delete_if { |s| s.include?(path) }
      require path
    end

    private
    def self.get_module_name(path)
      path.split('/').last.split('.').first.camelcase.to_sym
    end

  end
end