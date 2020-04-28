require "rack-proxy"

require_relative "server_store"

module StaticRails
  class ProxyMiddleware < Rack::Proxy
    def initialize(app)
      @app = app
      @servers = {}
      super
    end

    def perform_request(env)
      return @app.call(env) unless StaticRails.config.proxy_requests

      request = Rack::Request.new(env)
      server_store = ServerStore.instance
      server_store.ensure_servers_are_up

      if (site = site_request_should_be_forwarded_to(request))
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

    def site_request_should_be_forwarded_to(request)
      StaticRails.config.sites.find { |site|
        subdomain_match?(site, request) && path_match?(site, request)
      }
    end

    def forwarding_path(site, request)
      site.server_path + request.path.gsub(/^#{site.url_root_path}/, "")
    end

    def subdomain_match?(site, request)
      return true if site.url_subdomain.nil?

      expected = site.url_subdomain.split(".")
      actual = request.host.split(".")

      expected.enum_for.with_index.all? { |sub, i| actual[i] == sub }
    end

    def path_match?(site, request)
      request.path.start_with?(site.url_root_path)
    end
  end
end
