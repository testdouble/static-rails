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
        if (result = serve_file_for(file_handler, site, path, req))
          return result
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

    def serve_file_for(file_handler, site, path, req)
      if (found = file_handler.find_file(path, accept_encoding: req.accept_encoding))
        serve_file(file_handler, found, req)
      elsif site.compile_404_file_path.present?
        found = file_handler.find_file(site.compile_404_file_path, accept_encoding: req.accept_encoding)
        serve_file(file_handler, found, req, 404)
      end
    end

    def serve_file(file_handler, file, req, status_override = nil)
      return unless file
      file_handler.serve(req, *file).tap do |result|
        result[0] = status_override unless status_override.nil?
        override_cache_control_if_we_probably_shouldnt_cache!(result[1], file)
      end
    end

    PROBABLY_SHOULDNT_CACHE_MIME_TYPES = [
      "text/html", "application/xml", "application/rss+xml"
    ]
    def override_cache_control_if_we_probably_shouldnt_cache!(headers, file)
      mime_type = file[1]["Content-Type"]
      if PROBABLY_SHOULDNT_CACHE_MIME_TYPES.include?(mime_type)
        headers["cache-control"] = "no-cache, no-store"
      end
    end
  end
end
