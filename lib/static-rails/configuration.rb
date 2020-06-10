require_relative "site"

module StaticRails
  def self.config(&blk)
    @configuration ||= Configuration.new

    @configuration.tap do |config|
      blk&.call(config)
    end
  end

  class Configuration
    # When Rails invokes our Railtie, we'll save off a reference to the Rails app
    attr_accessor :app

    # When true, our middleware will proxy requests to static site servers
    attr_accessor :proxy_requests

    # When true, our middleware will serve sites' compiled asset files
    attr_accessor :serve_compiled_assets

    # Number of seconds to wait on sites to confirm servers are ready
    attr_accessor :ping_server_timeout

    # When true, a cookie named "_csrf_token" will be set by static-rails middleware
    attr_accessor :set_csrf_token_cookie

    # When true, skip starting servers when their port is already accepting connections
    attr_accessor :dont_start_server_if_port_already_bound

    def initialize
      @sites = []
      @proxy_requests = !Rails.env.production?
      @serve_compiled_assets = Rails.env.production?
      @ping_server_timeout = 5
      @set_csrf_token_cookie = false
      @dont_start_server_if_port_already_bound = Rails.env.test?
    end

    attr_reader :sites
    def sites=(sites)
      @sites = Array.wrap(sites).map { |site|
        Site.new(site)
      }
    end
  end
end
