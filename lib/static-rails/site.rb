module StaticRails
  class Site < Struct.new(
    :name,
    :url_subdomain,
    :url_root_path,
    :source_dir,
    :serve_command,
    :serve_host,
    :serve_port,
    :serve_path,
    :compile_command,
    :compile_dir,
    keyword_init: true
  )
  end
end
