StaticRails.config do |config|
  # config.proxy_requests = true

  config.sites = [
    {
      name: "blog-docs",
      url_subdomain: "blog",
      url_root_path: "/docs",
      source_dir: "static/blog-docs",
      server_command: "npx @11ty/eleventy --serve --pathprefix /docs",
      server_port: 8080,
      compile_command: "npx @11ty/eleventy --pathprefix /docs",
      compile_dir: "static/blog-docs/_site"
    },
    {
      name: "blog",
      url_subdomain: "blog",
      url_root_path: "/",
      source_dir: "static/blog",
      server_command: "hugo server --disableLiveReload",
      server_port: 1313,
      compile_command: "hugo",
      compile_dir: "static/blog/public"
    },
    {
      name: "docs",
      url_root_path: "/docs",
      source_dir: "static/docs",
      server_command: "bundle exec jekyll serve",
      server_port: 4000,
      compile_command: "bundle exec jekyll build",
      compile_dir: "static/docs/_site"
    },
    {
      name: "marketing",
      url_root_path: "/marketing",
      source_dir: "static/marketing",
      server_command: "hugo server -p 1314 --disableLiveReload",
      server_port: 1314,
      compile_command: "hugo",
      compile_dir: "static/marketing/public"
    }
  ]
end
