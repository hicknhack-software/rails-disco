require 'active_event'
require 'active_projection'
ActiveEvent::Autoload.app_path = File.expand_path('../../../app', __FILE__)
ActiveProjection::Autoload.app_path = File.expand_path('../../../app', __FILE__)
ActiveEvent::ValidationsRegistry.build