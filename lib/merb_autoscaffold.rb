require 'merb_autoscaffold/controller'
require 'merb_autoscaffold/models'

if defined?(Merb::Plugins)
  Merb::BootLoader.before_app_loads do
    Merb::Plugins.config[:merb_autoscaffold] = {}
  end

  dependency "paginator"

  Merb::BootLoader.after_app_loads do
    Merb::Plugins.config[:merb_autoscaffold][:namespace] ||= 'scaffolds'

    Merb::Router.prepend { |r|
      path = Merb::Plugins.config[:merb_autoscaffold][:namespace].to_s
      r.namespace( :scaffold, :path => path )do |scaffold|
        MerbAutoScaffold::Models.all.each_with_index do |model, i|
          MerbAutoScaffold::Controller.new( model )
          # this does not work, thus the explicit way below
          # scaffold.match("/").to(:controller => model.plural_name.to_s, :action => 'index') if i == 0
          r.match("/" + path).to(:controller => 'scaffold/' + model.plural_name.to_s, :action => 'index') if i == 0
          scaffold.resources model.plural_name
        end
      end
    }
  end

  Merb::Plugins.add_rakefiles "merb_autoscaffold/merbtasks"
end