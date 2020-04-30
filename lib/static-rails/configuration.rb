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

    # When true, the ProxyMiddleware will be added
    attr_accessor :proxy_requests

    # When true, the StaticMiddleware will be added
    attr_accessor :serve_compiled_assets

    # Number of seconds to wait on sites to confirm servers are ready
    attr_accessor :ping_server_timeout

    def initialize
      @sites = []
      @proxy_requests = !Rails.env.production?
      @serve_compiled_assets = Rails.env.production?
      @ping_server_timeout = 5
    end

    attr_reader :sites
    def sites=(sites)
      @sites = Array.wrap(sites).map { |site|
        Site.new(site)
      }
    end
  end
end
