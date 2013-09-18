require 'active_event'
require 'active_projection'
ActiveEvent::Autoload.app_path = File.expand_path('../../..', __FILE__)
ActiveProjection::Autoload.app_path = File.expand_path('../../..', __FILE__)

watchable_dirs = ActiveEvent::Autoload.watchable_dirs.merge ActiveProjection::Autoload.watchable_dirs
RELOADER = ActiveSupport::FileUpdateChecker.new([], watchable_dirs) do
  ActiveEvent::Autoload.reload_module :ValidationsRegistry
  ActiveEvent::Autoload.reload
  ActiveProjection::Autoload.reload
  ActiveEvent::ValidationsRegistry.build
end

ActionDispatch::Reloader.to_prepare do
  RELOADER.execute_if_updated
end

ActiveEvent::ValidationsRegistry.build