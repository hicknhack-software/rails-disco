module ActiveProjection
  module Autoload
    def self.worker_config=(config)
      dirs = []
      projections_dir = "#{config[:path]}**/*.rb"
      if config[:count] == 1
        dirs << projections_dir
      else
        Dir[*projections_dir].each_with_index.map { |item, i| i % config[:count] == config[:number] ? item : nil }.compact.each do |dir|
          dirs << dir
        end
      end
      ActiveEvent::Support::Autoloader.load_from dirs
    end

    def self.app_path=(path)
      ActiveEvent::Support::Autoloader.load_from "#{path}/models/**/*.rb"
    end
  end
end