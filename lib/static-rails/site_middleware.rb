require_relative "proxy_middleware"
require_relative "static_middleware"

module StaticRails
  class SiteMiddleware
    def initialize(app)
      @app = app
      @proxy_middleware = ProxyMiddleware.new(app)
      @static_middleware = StaticMiddleware.new(app)
      @matches_request_to_static_site = MatchesRequestToStaticSite.new
    end

    def call(env)
      return @app.call(env) unless handle_request?(Rack::Request.new(env))

      status, headers, body = if StaticRails.config.proxy_requests
        @proxy_middleware.call(env)
      elsif StaticRails.config.serve_compiled_assets
        @static_middleware.call(env)
      end
      if StaticRails.config.set_csrf_token_cookie
        res = Rack::Response.new(body, status, headers)
        csrf_body = fake_request_csrf_from_middleware_deeper_than_session_store(env)
        res.set_cookie("_csrf_token", {
          value: csrf_body,
          path: "/"
        })
        res.finish
      else
        [status, body, headers]
      end
    end

    private

    def handle_request?(req)
      (req.get? || req.head?) &&
        (StaticRails.config.proxy_requests || StaticRails.config.serve_compiled_assets) &&
        @matches_request_to_static_site.call(req)
    end

    def fake_request_csrf_from_middleware_deeper_than_session_store(env)
      _, _, csrf_token_body = @app.call(env.merge(
        "__static_rails_evil_request_for_csrf_token" => true
      ))
      csrf_body = ""
      csrf_token_body.each do |s|
        csrf_body << s
      end
      csrf_token_body.close
      csrf_body
    end
  end
end
