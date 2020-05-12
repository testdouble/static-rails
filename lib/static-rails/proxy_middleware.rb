require "rack-proxy"

require_relative "matches_request_to_static_site"
require_relative "sets_csrf_token"
require_relative "server_store"

module StaticRails
  class ProxyMiddleware < Rack::Proxy
    def initialize(app)
      @matches_request_to_static_site = MatchesRequestToStaticSite.new
      @sets_csrf_token = SetsCsrfToken.new
      @app = app
      @servers = {}
      super
    end

    def perform_request(env)
      return @app.call(env) unless StaticRails.config.proxy_requests

      server_store = ServerStore.instance
      server_store.ensure_all_servers_are_started
      server_store.ensure_servers_are_up

      req = Rack::Request.new(env)
      if (req.get? || req.head?) && (site = @matches_request_to_static_site.call(req))
        if site.ping_server && (server = server_store.server_for(site))
          server.wait_until_ready
        end

        @backend = URI("http://#{site.server_host}:#{site.server_port}")
        env["HTTP_HOST"] = @backend.host
        env["PATH_INFO"] = forwarding_path(site, req)

        status, headers, body = super(env)
        res = Rack::Response.new(body, status, headers)
        @sets_csrf_token.call(req, res) if StaticRails.config.set_csrf_token_cookie
        res.finish
      else
        @app.call(env)
      end
    end

    private

    def forwarding_path(site, req)
      req_path = req.path_info

      if req_path == site.url_root_path && !req_path.end_with?("/")
        req_path + "/" # <- Necessary for getting jekyll, possibly hugo to serve the root
      else
        req_path
      end
    end
  end
end
