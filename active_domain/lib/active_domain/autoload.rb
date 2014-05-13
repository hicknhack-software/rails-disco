module ActiveDomain
  module Autoload
    include ActiveEvent::Support::Autoload

    private

    def self.dir_names
      %w(domain/command_processors domain/validations domain/models domain/projections)
    end
  end
end
