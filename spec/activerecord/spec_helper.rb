# Credit: thanks to BrianTheCoder for illustrating how to properly construct
# tests for merb gems: http://github.com/BrianTheCoder/can_has_auth

$TESTING=true
__DIR__ = File.dirname(__FILE__)
$:.push File.join(__DIR__, '..', '..', 'lib')

require 'rubygems'
require 'merb-core'
require 'spec'
require 'data_mapper'
require 'activerecord'
require 'ruby-debug'

# DataMapper::Persistence.auto_migrate!
# DataMapper::Database.setup({:adapter => "sqlite3", :database => "test.db"})
ActiveRecord::Base.establish_connection( :adapter => 'sqlite3', :database => 'test.db' )

Merb::BootLoader.before_app_loads do
  require 'merb_autoscaffold'
end

# Merb::BootLoader.after_app_loads do
# end

Merb.start_environment(
  :testing       => true,
  :adapter       => 'runner',
  :environment   => 'test',
  :session_store => 'memory',
  :merb_root     => __DIR__,
  :init_file     => __DIR__ / 'init'
)

Spec::Runner.configure do |config|
  config.include(Merb::Test::ViewHelper)
  config.include(Merb::Test::RouteHelper)
  config.include(Merb::Test::ControllerHelper)
end


