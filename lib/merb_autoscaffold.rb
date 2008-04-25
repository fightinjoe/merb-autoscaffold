require 'merb_autoscaffold/controller'
require 'merb_autoscaffold/models'

if defined?(Merb::Plugins)
  Merb::Plugins.config[:merb_autoscaffold] = {
    :chickens => false
  }

  Merb::BootLoader.before_app_loads do
  end

  Merb::BootLoader.after_app_loads do
    # Find the models
    for model in MerbAutoScaffold::Models.all
      # Add the controllers
      MerbAutoScaffold::Controller.new( model )
      # Add the routes
      Merb::Router.prepend { |r| r.resources model.plural_name }
    end
  end

  Merb::Plugins.add_rakefiles "merb_autoscaffold/merbtasks"
end