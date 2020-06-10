require_relative "rack_server_check"
require_relative "should_skip_starting_servers"
require_relative "server_store"
require_relative "site_middleware"
require_relative "site_plus_csrf_middleware"

module StaticRails
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load "tasks/static-rails.rake"
    end

    initializer "static_rails.middleware" do
      config.app_middleware.insert_before 0, SiteMiddleware
      config.app_middleware.use SitePlusCsrfMiddleware
    end

    config.after_initialize do |app|
      static_rails_config = StaticRails.config
      static_rails_config.app = app

      if RackServerCheck.running? && !ShouldSkipStartingServers.new.call
        ServerStore.instance.ensure_all_servers_are_started
      end
    end
  end
end
