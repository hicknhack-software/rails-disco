module ActiveEvent
  module Autoload
    include ActiveEvent::Support::Autoload
    private
    def self.dir_names
      %W(app/commands app/validations app/events)
    end
  end
end
