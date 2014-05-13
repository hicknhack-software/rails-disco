require 'rbconfig'
require 'disco/app_disco_loader'

# If we are inside a Rails application this method performs an exec and thus
# the rest of this script is not run.
Disco::AppDiscoLoader.exec_app_disco

require 'rails/ruby_version_check'
Signal.trap('INT') do
  puts
  exit(1)
end

require 'disco/commands/application'
