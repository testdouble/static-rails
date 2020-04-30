require_relative "rack_server_check"
require_relative "server_store"
require_relative "proxy_middleware"

module StaticRails
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load "tasks/static-rails.rake"
    end

    # Note that user initializer won't have run yet, but we seem to need to
    # register the middleware by now if it's going to properly get added to the
    # stack. So if the user overrides this setting, the middleware will still
    # be added but will be responsible itself for skipping each request (bummer)
    if RackServerCheck.running? && StaticRails.config.proxy_requests
      config.app_middleware.insert_before 0, ProxyMiddleware
    end

    config.after_initialize do |app|
      static_rails_config = StaticRails.config
      static_rails_config.app = app

      if RackServerCheck.running?
        server_store = ServerStore.instance
        static_rails_config.sites.select(&:start_server).each do |site|
          server_store.server_for(site).start
        end
      end
    end
  end
end
