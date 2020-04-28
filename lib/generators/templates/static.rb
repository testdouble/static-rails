StaticRails.config do |config|
  # Control whether static-rails adds a middleware to proxy requests to your static site servers
  # config.proxy_requests = !Rails.env.production?

  # Timeout in seconds to wait when proxying to  a static server
  #   (Applies when a site has both start_server and ping_server set to true)
  # config.ping_server_timeout = 5

  config.sites = [
    # {
    #   # Unique name for the site
    #   name: "blog",
    #
    #   # File path to the static app relative to Rails root path
    #   source_dir: "static/blog",
    #
    #   # Constrain static app to the following subdomain (omit or leave nil if you aren't hosting the site on a subdomain)
    #   url_subdomain: "blog",
    #
    #   # Mount the static site web hosting to a certain sub-path (e.g. "/docs")
    #   url_root_path: "/",
    #
    #   # Whether to run the local development/test server or not
    #   start_server: !Rails.env.production?,
    #
    #   # If start_server is true, wait to proxy requests to the server until it can connect to serve_host over TCP on serve_port
    #   ping_server: true
    #
    #   # The command to execute when running the static app in local development/test environments
    #   serve_command: "hugo server",
    #
    #   # The host the local development/test server should be reached on
    #   serve_host: "localhost",
    #
    #   # The port the local development/test server should be reached on
    #   serve_port: "1313",
    #
    #   # The root path on the local development/test server to which requests should be forwarded
    #   serve_path: "/",
    #
    #   # The command to execute when building the static app for production
    #   compile_command: "hugo",
    #
    #   # The destination of the production-compiled assets, relative to Rails root
    #   compile_dir: "static/blog/dist"
    # },
  ]
end
