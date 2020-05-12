require_relative "rack_server_check"
require_relative "server_store"
require_relative "proxy_middleware"
require_relative "static_middleware"

module StaticRails
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load "tasks/static-rails.rake"
    end

    # Note that user initializer won't have run yet, but we seem to need to
    # register the middleware by now if it's going to properly get added to the
    # stack. So if the user overrides these flags' defaults, the middleware will
    # still be added but will be responsible itself for skipping each request
    initializer "static_rails.middleware" do
      if StaticRails.config.proxy_requests
        config.app_middleware.insert_after ActionDispatch::Session::CookieStore, ProxyMiddleware
      elsif StaticRails.config.serve_compiled_assets
        config.app_middleware.insert_after ActionDispatch::Session::CookieStore, StaticMiddleware
      end
    end

    config.after_initialize do |app|
      static_rails_config = StaticRails.config
      static_rails_config.app = app

      if RackServerCheck.running?
        ServerStore.instance.ensure_all_servers_are_started
      end
    end
  end
end
