require_relative "rack_server_check"
require_relative "server_store"
require_relative "conditional_cookies_middleware"
require_relative "conditional_session_cookie_store_middleware"
require_relative "site_middleware"

module StaticRails
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load "tasks/static-rails.rake"
    end

    initializer "static_rails.middleware" do
      config.app_middleware.insert_after ActionDispatch::Session::CookieStore, SiteMiddleware
      # config.app_middleware.insert_before 0, ConditionalSessionCookieStoreMiddleware
      # config.app_middleware.insert_before 0, ConditionalCookiesMiddleware
      # config.app_middleware.insert_before 0, ActionDispatch::Session::CookieStore
      # config.app_middleware.insert_before 0, ActionDispatch::Cookies
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
