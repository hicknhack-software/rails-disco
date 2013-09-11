module ActiveEvent::Support
  module Autoloader
    def self.load_from(dirs)
      Dir[*dirs].each do |file|
        require file
      end
    end
  end
end