require 'active_support/configurable'

module RailsAuth #:nodoc:
  include ActiveSupport::Configurable

  configure do |config|
    config.app_controller = 'ApplicationController'
    config.my_controller = 'MyController'
    config.admin_controller = 'AdminController'
    config.record_class = 'ApplicationRecord'
    config.default_return_path = '/'
    config.ignore_return_paths = [
      'login',
      'join'
    ]
    config.enable_access_counter = false
  end

end


