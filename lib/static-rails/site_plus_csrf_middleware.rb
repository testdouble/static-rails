require_relative "site_middleware"
require_relative "determines_whether_to_handle_request"
require_relative "gets_csrf_token"

module StaticRails
  class SitePlusCsrfMiddleware < SiteMiddleware
    def initialize(app)
      @determines_whether_to_handle_request = DeterminesWhetherToHandleRequest.new
      @gets_csrf_token = GetsCsrfToken.new
      super
    end

    def call(env)
      return @app.call(env) unless @determines_whether_to_handle_request.call(env)

      env = env.merge(
        "PATH_INFO" => env["PATH_INFO"].gsub(/#{PATH_INFO_OBFUSCATION}/, "")
      )
      status, headers, body = super(env)

      if StaticRails.config.set_csrf_token_cookie
        req = Rack::Request.new(env)
        res = Rack::Response.new(body, status, headers)
        token = @gets_csrf_token.call(req)
        puts "SETTING _csrf_token to '#{token}' for host  #{req.host}"
        res.set_cookie("_csrf_token", {
          value: token,
          path: "/"
        })
        res.finish
      else
        [status, headers, body]
      end
    end

    protected

    def require_csrf_before_processing_request?
      false
    end
  end
end
