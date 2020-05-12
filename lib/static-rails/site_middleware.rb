require_relative "proxy_middleware"
require_relative "static_middleware"
require_relative "determines_whether_to_handle_request"
require_relative "gets_csrf_token"

module StaticRails
  class SiteMiddleware
    def initialize(app)
      @app = app
      @proxy_middleware = ProxyMiddleware.new(app)
      @static_middleware = StaticMiddleware.new(app)
      @determines_whether_to_handle_request = DeterminesWhetherToHandleRequest.new
      @gets_csrf_token = GetsCsrfToken.new
    end

    def call(env)
      return @app.call(env) unless @determines_whether_to_handle_request.call(env)

      status, headers, body = if StaticRails.config.proxy_requests
        @proxy_middleware.call(env)
      elsif StaticRails.config.serve_compiled_assets
        @static_middleware.call(env)
      end

      if StaticRails.config.set_csrf_token_cookie
        req = Rack::Request.new(env)
        res = Rack::Response.new(body, status, headers)
        res.set_cookie("_csrf_token", {
          value: @gets_csrf_token.call(req)
        })
        res.finish
      else
        [status, headers, body]
      end
    end
  end
end
