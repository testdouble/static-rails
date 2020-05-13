module StaticRails
  class DeterminesWhetherToHandleRequest
    def initialize
      @matches_request_to_static_site = MatchesRequestToStaticSite.new
    end

    def call(env)
      req = Rack::Request.new(env)

      (req.get? || req.head?) &&
        (StaticRails.config.proxy_requests || StaticRails.config.serve_compiled_assets) &&
        @matches_request_to_static_site.call(req)
    end
  end
end
