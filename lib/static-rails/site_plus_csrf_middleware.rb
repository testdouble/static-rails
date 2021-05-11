require_relative "site_middleware"
require_relative "determines_whether_to_handle_request"
require_relative "validates_csrf_token"
require_relative "gets_csrf_token"

module StaticRails
  class SitePlusCsrfMiddleware < SiteMiddleware
    def initialize(app)
      @determines_whether_to_handle_request = DeterminesWhetherToHandleRequest.new
      @validates_csrf_token = ValidatesCsrfToken.new
      @gets_csrf_token = GetsCsrfToken.new
      super
    end

    def call(env)
      return @app.call(env) unless env["PATH_INFO"]&.start_with?(/\/?#{PATH_INFO_OBFUSCATION}/o) || @determines_whether_to_handle_request.call(env)

      env = env.merge(
        "PATH_INFO" => env["PATH_INFO"].gsub(/^\/?#{PATH_INFO_OBFUSCATION}/o, "")
      )
      status, headers, body = super(env)

      if StaticRails.config.set_csrf_token_cookie
        req = Rack::Request.new(env)
        res = Rack::Response.new(body, status, headers)
        if needs_new_csrf_token?(req)
          res.set_cookie("_csrf_token", {
            value: @gets_csrf_token.call(req),
            path: "/"
          })
        end
        res.finish
      else
        [status, headers, body]
      end
    end

    protected

    def require_csrf_before_processing_request?
      false
    end

    private

    def needs_new_csrf_token?(req)
      !req.cookies.has_key?("_csrf_token") || !@validates_csrf_token.call(req)
    end
  end
end
