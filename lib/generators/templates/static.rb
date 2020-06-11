StaticRails.config do |config|
  # Control whether static-rails adds a middleware to proxy requests to your static site servers
  # config.proxy_requests = !Rails.env.production?

  # Control whether static-rails adds a middleware to serve your sites' compiled static assets with Static::Rack (has no effect if proxy_requests is enabled)
  # config.serve_compiled_assets = Rails.env.production?

  # Timeout in seconds to wait when proxying to  a static server
  #   (Applies when a site has both start_server and ping_server set to true)
  # config.ping_server_timeout = 5

  # When true, both the proxy & static asset middleware will set a cookie
  #   named "_csrf_token" to the Rails CSRF token, allowing any client-side
  #   API requests to take advantage of Rails' request forgery protection
  # config.set_csrf_token_cookie = false

  # The list of static sites you are hosting with static-rails.
  # Note that order matters! Request will be forwarded to the first site that
  # matches the subdomain and root path (this probably means you want any sites
  # with subdomains listed first)
  config.sites = [
    # {
    #   # Unique name for the site
    #   name: "blog",
    #
    #   # File path to the static app relative to Rails root path
    #   source_dir: "static/blog",
    #
    #   # Constrain static app to the following subdomain (omit or leave nil
    #   #   if you aren't hosting the site on a subdomain)
    #   url_subdomain: "blog",
    #
    #   # Mount the static site web hosting to a certain sub-path (e.g. "/docs")
    #   url_root_path: "/",
    #
    #   # Don't serve/redirect routes whose paths start with these strings
    #   url_skip_paths_starting_with: ["/api"],
    #
    #   # Whether to run the local development/test server or not
    #   start_server: !Rails.env.production?,
    #
    #   # If start_server is true, wait to proxy requests to the server until it
    #   #   can connect to server_host over TCP on server_port
    #   ping_server: true,
    #
    #   # Any environment variables you need to pass to the server & compile
    #   #   commands as a hash (e.g. `env: {"BUNDLE_PATH" => "vendor/bundle"}`)
    #   env: {},
    #
    #   # The command to execute when running the static app in local
    #   #   development/test environments
    #   server_command: "hugo server",
    #
    #   # The host the local development/test server should be reached on
    #   server_host: "localhost",
    #
    #   # The port the local development/test server should be reached on
    #   server_port: "1313",
    #
    #   # The root path on the local development/test server to which requests
    #   #   should be forwarded
    #   server_path: "/",
    #
    #   # The command to execute when building the static app for production
    #   compile_command: "hugo",
    #
    #   # The destination of production-compiled assets, relative to Rails root
    #   compile_dir: "static/blog/dist",
    #
    #   # A 404 page to be sent when serving compiled assets and no file matches
    #   compile_404_file_path: "404.html"
    # },
  ]
end
