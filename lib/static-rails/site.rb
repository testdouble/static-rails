module StaticRails
  class Site < Struct.new(
    :name,
    :url_subdomain,
    :url_root_path,
    :source_dir,
    :start_server,
    :ping_server,
    :server_command,
    :server_host,
    :server_port,
    :server_path,
    :compile_command,
    :compile_dir,
    keyword_init: true
  )

    def initialize(
      start_server: !Rails.env.production?,
      ping_server: true,
      server_host: "localhost",
      server_path: "/",
      **other_kwargs
    )
      @start_server = start_server
      @server_host = server_host
      @server_path = server_path
      @ping_server = ping_server
      super
    end
  end
end
