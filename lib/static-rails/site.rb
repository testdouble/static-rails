module StaticRails
  class Site < Struct.new(
    :name,
    :url_subdomain,
    :url_root_path,
    :url_skip_paths_starting_with,
    :source_dir,
    :start_server,
    :ping_server,
    :env,
    :server_command,
    :server_host,
    :server_port,
    :server_path,
    :compile_command,
    :compile_dir,
    keyword_init: true
  )

    def initialize(
      url_root_path: "/",
      url_skip_paths_starting_with: [],
      start_server: !Rails.env.production?,
      ping_server: true,
      env: {},
      server_host: "localhost",
      server_path: "/",
      **other_kwargs
    )
      @url_root_path = url_root_path
      @url_skip_paths_starting_with = url_skip_paths_starting_with
      @start_server = start_server
      @ping_server = ping_server
      @env = env
      @server_host = server_host
      @server_path = server_path
      super
    end
  end
end
