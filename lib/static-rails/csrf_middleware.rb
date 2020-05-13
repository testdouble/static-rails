require_relative "gets_csrf_token"

module StaticRails
  class CsrfMiddleware
    def initialize(app)
      @app = app
      @gets_csrf_token = GetsCsrfToken.new
    end

    def call(env)
      if env["__static_rails_evil_request_for_csrf_token"]
        req = Rack::Request.new(env)
        [200, {}, [@gets_csrf_token.call(req)]].tap do
        end
      else
        @app.call(env)
      end
    end
  end
end
