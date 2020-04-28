StaticRails.configure do |config|
  config.sites = [
    # {
    #   # Name for display purposes only
    #   name: "Blog",
    #
    #   # Constrain static app to the following subdomain (omit or leave nil if you aren't hosting the site on a subdomain)
    #   url_subdomain: "blog",
    #
    #   # Mount the static site web hosting to a certain sub-path (e.g. "/docs")
    #   url_root_path: "/",
    #
    #   # File path to the static app relative to Rails root path
    #   source_dir: "static/blog",
    #
    #   # The command to execute when running the static app in local development/test environments
    #   serve_command: "hugo server",
    #
    #   # The URL to prepend when forwarding requests from the Rails app to your development/test server
    #   serve_url: "http://localhost:1313",
    #
    #   # The command to execute when building the static app for production
    #   compile_command: "hugo",
    #
    #   # The destination of the production-compiled assets, relative to Rails root
    #   compile_dir: "static/blog/dist"
    # },
  ]
end
