module ActiveEvent
  module Support
    module Autoload
      extend ActiveSupport::Concern
      module ClassMethods
        def app_path=(path)
          self.dir_path = path
          Autoloader.load_from dirs
        end

        def reload_module(module_name)
          path = [parent.name, module_name.to_s].join('::').underscore
          Autoloader.reload module_name, path
        end

        def reload
          Autoloader.reload_from dirs
        end

        def watchable_dirs
          watchable_dirs = {}
          dir_names.each do |dir_name|
            watchable_dirs[dir_name] = [:rb]
          end
          watchable_dirs
        end

        private

        def dir_names
          []
        end

        def dir_path=(path)
          @dirs = dir_names.map do |dir_name|
            "#{path}/#{dir_name}/**/*.rb"
          end
        end

        def dirs
          @dirs ||= ''
        end
      end
    end
  end
end
