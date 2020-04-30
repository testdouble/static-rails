require "rack-proxy"

require_relative "matches_request_to_static_site"
require_relative "server_store"

module StaticRails
  class ProxyMiddleware < Rack::Proxy
    def initialize(app)
      @matches_request_to_static_site = MatchesRequestToStaticSite.new
      @app = app
      @servers = {}
      super
    end

    def perform_request(env)
      return @app.call(env) unless StaticRails.config.proxy_requests

      request = Rack::Request.new(env)
      server_store = ServerStore.instance
      server_store.ensure_servers_are_up

      if (req.get? || req.head?) && (site = @matches_request_to_static_site.call(request))
        if site.ping_server && (server = server_store.server_for(site))
          server.wait_until_ready
        end

        @backend = URI("http://#{site.server_host}:#{site.server_port}")

        env["HTTP_HOST"] = @backend.host
        env["PATH_INFO"] = forwarding_path(site, request)
        env["HTTP_COOKIE"] = ""
        super(env)
      else
        @app.call(env)
      end
    end

    private

    def forwarding_path(site, request)
      if request.path == site.url_root_path && !request.path.end_with?("/")
        request.path + "/" # <- Necessary for getting jekyll, possibly hugo to serve the root
      else
        request.path
      end
    end
  end
end
