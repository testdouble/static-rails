require "rack-proxy"

require_relative "site"
require_relative "server"

module StaticRails
  class Middleware < Rack::Proxy
    def initialize(app)
      @app = app
      @sites = nil # must be initiated later after Rails is fully initialized :-/
      @servers = {}
      super
    end

    def perform_request(env)
      request = Rack::Request.new(env)

      initialize_sites_if_necessary!
      start_servers_if_necessary!

      if (site = site_request_should_be_forwarded_to(request))
        @backend = URI("http://#{site.serve_host}:#{site.serve_port}")

        env["HTTP_HOST"] = @backend.host

        env["PATH_INFO"] = forwarding_path(site, request)

        env["HTTP_COOKIE"] = ""
        super(env)
        # TODO if this 404s fall through to the rails app maybe
      else
        @app.call(env)
      end
    end

    private

    def initialize_sites_if_necessary!
      return unless @sites.nil?
      @sites = StaticRails.sites.map { |site| Site.new(site) }
    end

    def start_servers_if_necessary!
      @sites.each do |site|
        server = @servers[site] ||= Server.new(@app, site)
        server.start unless server.started?
      end
    end

    def site_request_should_be_forwarded_to(request)
      @sites.find { |site|
        subdomain_match?(site, request) && path_match?(site, request)
      }
    end

    def forwarding_path(site, request)
      site.serve_path + request.path.gsub(/^#{site.url_root_path}/, "")
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
