require_relative "proxy_middleware"
require_relative "static_middleware"
require_relative "determines_whether_to_handle_request"
require_relative "gets_csrf_token"

module StaticRails
  class SiteMiddleware
    PATH_INFO_OBFUSCATION = "JujJVj31M3SpzTjIGBJ2-3iE0lKXOIOlbLuk9Lxwe-Ll2uLuwH5KD8dmt1MqyZ"

    def initialize(app)
      @app = app
      @proxy_middleware = ProxyMiddleware.new(app)
      @static_middleware = StaticMiddleware.new(app)
      @determines_whether_to_handle_request = DeterminesWhetherToHandleRequest.new
    end

    def call(env)
      return @app.call(env) unless @determines_whether_to_handle_request.call(env)

      if require_csrf_before_processing_request? && !csrf_token_is_set?(env)
        @app.call(env.merge("PATH_INFO" => env["PATH_INFO"] + PATH_INFO_OBFUSCATION))
      elsif StaticRails.config.proxy_requests
        @proxy_middleware.call(env)
      elsif StaticRails.config.serve_compiled_assets
        @static_middleware.call(env)
      end
    end

    protected

    # Override this in subclass since it'll call super(env) and deal itself
    def require_csrf_before_processing_request?
      StaticRails.config.set_csrf_token_cookie
    end

    def csrf_token_is_set?(env)
      Rack::Request.new(env).cookies.has_key?("_csrf_token")
    end
  end
end
