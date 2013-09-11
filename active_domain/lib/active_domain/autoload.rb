module ActiveDomain
  module Autoload
    def self.app_path=(path)
      dirs = []
      dirs << "#{path}/command_processors/**/*.rb"
      dirs << "#{path}/validations/**/*.rb"
      dirs << "#{path}/projections/**/*.rb"
      dirs << "#{path}/models/**/*.rb"
      ActiveEvent::Support::Autoloader.load_from dirs
    end
  end
end