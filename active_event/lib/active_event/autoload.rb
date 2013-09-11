module ActiveEvent
  module Autoload
    def self.app_path=(path)
      dirs = []
      dirs << "#{path}/commands/**/*.rb"
      dirs << "#{path}/validations/**/*.rb"
      dirs << "#{path}/events/**/*.rb"
      ActiveEvent::Support::Autoloader.load_from dirs
    end
  end
end