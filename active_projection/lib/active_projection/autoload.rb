module ActiveProjection
  module Autoload
    include ActiveEvent::Support::Autoload
    private
    def self.dir_names
      %W(app/models)
    end

    def self.reload
      ActiveEvent::Support::Autoloader.reload_from pdirs
      super
    end

    def self.worker_config=(config)
      set_pdirs config
      ActiveEvent::Support::Autoloader.load_from pdirs
    end

    def self.watchable_dirs
      watchable_dirs = super
      watchable_dirs['app/projections'] = [:rb]
      watchable_dirs
    end

    private
    def self.set_pdirs(config)
      @pdirs = []
      projections_dir = "#{config[:path]}/app/projections/**/*.rb"
      if config[:count] == 1
        @pdirs << projections_dir
      else
        Dir[*projections_dir].each_with_index.map { |item, i| i % config[:count] == config[:number] ? item : nil }.compact.each do |dir|
          @pdirs << dir
        end
      end
    end

    def self.pdirs
      @pdirs ||= []
    end
  end
end