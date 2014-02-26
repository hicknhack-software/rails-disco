require 'rbconfig'
require 'drails/app_drails_loader'

# If we are inside a Rails application this method performs an exec and thus
# the rest of this script is not run.
Drails::AppDrailsLoader.exec_app_drails

require 'rails/ruby_version_check'
Signal.trap('INT') { puts; exit(1) }

require 'drails/commands/application'
