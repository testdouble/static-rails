require_relative "proxy_middleware"
require_relative "static_middleware"
require_relative "determines_whether_to_handle_request"

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

      if require_csrf_before_processing_request?
        # You might be asking yourself what the hell is going on here. In short,
        # This middleware sits at the top of the stack, which is too early to
        # set a CSRF token in a cookie. Therefore, we've placed a subclass of
        # this middleware named SitePlusCsrfMiddleware near the bottom of the
        # middleware stack, which is slower but comes after Session::CookieStore
        # and therefore can write _csrf_token to the cookie. As a result, the
        # observable behavior to the user is identical, but the first request
        # to set the cookie will be marginally slower because it needs to go
        # deeper down the Rails middleware stack
        #
        # But! Between these two is ActionDispatch::Static. In the odd case that
        # a path that this middleware would serve happens to match the name of
        # a path in public/, kicking down the middleware stack would result in
        # that file being served instead of our deeper middleware being called.
        # So to work around this we're just making the PATH_INFO property so
        # ugly that there's no chance it'll match anything. When our subclass
        # gets its shot at this request, it'll know to remove the path
        # obfuscation from PATH_INFO and go about its business.
        #
        # See, easy!
        #
        # (By the way, this was all Matthew Draper's bright idea. You can
        # compliment him here: https://github.com/matthewd )
        @app.call(env.merge("PATH_INFO" => PATH_INFO_OBFUSCATION + env["PATH_INFO"]))
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
  end
end
