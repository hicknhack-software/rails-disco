module ActiveProjection
  module Autoload
    include ActiveEvent::Support::Autoload
    private
    def self.dir_names
      %W(app/models app/projections)
    end
  end
end
