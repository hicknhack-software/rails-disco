module ActiveDomain
  module Autoload
    include ActiveEvent::Support::Autoload
    private
    def self.dir_names
      %W(domain/command_processors domain/validations domain/models domain/projections)
    end
  end
end