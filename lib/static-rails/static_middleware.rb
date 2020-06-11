require "rack-proxy"

require_relative "file_handler"
require_relative "matches_request_to_static_site"

module StaticRails
  class StaticMiddleware
    def initialize(app)
      @matches_request_to_static_site = MatchesRequestToStaticSite.new
      @app = app
      @file_handlers = {}
    end

    def call(env)
      return @app.call(env) unless StaticRails.config.serve_compiled_assets
      req = Rack::Request.new env

      if (req.get? || req.head?) && (site = @matches_request_to_static_site.call(req))
        file_handler = file_handler_for(site)
        path = req.path_info.gsub(/^#{site.url_root_path}/, "").chomp("/")
        if (found = find_file_for(file_handler, site, path, req.accept_encoding))
          return file_handler.serve(req, *found)
        end
      end

      @app.call(req.env)
    end

    private

    # The same file handler used by Rails when serving up files from /public
    #   See: actionpack/lib/action_dispatch/middleware/static.rb
    def file_handler_for(site)
      @file_handlers[site] ||= FileHandler.new(
        StaticRails.config.app.root.join(site.compile_dir).to_s,
        headers: {
          "cache-control" => "public; max-age=31536000"
        },
        compressible_content_types: /^text\/|[\/+](javascript|json|text|xml|css|yaml)$/i
      )
    end

    def find_file_for(file_handler, site, path, accept_encoding)
      if (found = file_handler.find_file(path, accept_encoding: accept_encoding))
        found
      elsif site.compile_404_file_path.present?
        file_handler.find_file(site.compile_404_file_path, accept_encoding: accept_encoding)
      end
    end
  end
end
