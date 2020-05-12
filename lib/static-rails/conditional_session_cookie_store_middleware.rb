require_relative "determines_whether_to_handle_request"

module StaticRails
  class ConditionalSessionCookieStoreMiddleware
    def initialize(app)
      @app = app
      @middleware = ActionDispatch::Session::CookieStore.new(app)
      @determines_whether_to_handle_request = DeterminesWhetherToHandleRequest.new
    end

    def call(env)
      if static_rails_will_handle_request_and_needs_cookies?(env)
        @middleware.call(env)
      else
        @app.call(env)
      end
    end

    private

    def static_rails_will_handle_request_and_needs_cookies?(env)
      StaticRails.config.set_csrf_token_cookie && @determines_whether_to_handle_request.call(env)
    end
  end
end
