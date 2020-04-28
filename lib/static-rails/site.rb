module StaticRails
  class Site < Struct.new(
    :name,
    :url_subdomain,
    :url_root_path,
    :source_dir,
    :start_server,
    :ping_server,
    :serve_command,
    :serve_host,
    :serve_port,
    :serve_path,
    :compile_command,
    :compile_dir,
    keyword_init: true
  )

    def initialize(
      start_server: !Rails.env.production?,
      ping_server: true,
      serve_host: "localhost",
      serve_path: "/",
      **other_kwargs
    )
      @start_server = start_server
      @serve_host = serve_host
      @serve_path = serve_path
      @ping_server = ping_server
      super
    end
  end
end
