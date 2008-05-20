use_orm :datamapper

Merb::BootLoader.before_app_loads do
  require 'merb_autoscaffold'
end