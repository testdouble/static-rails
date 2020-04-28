require "daemon_controller"

module StaticRails
  class Server
    def initialize(app, site)
      @app = app
      @site = site
      @controller = create_daemon_controller_for(site)
    end

    def start
      chdir file_path(@site.source_dir) do
        @controller.start
      end
    end

    private

    def create_daemon_controller_for(site)
      # chdir file_path(@site.source_dir) do
      DaemonController.new(
        identifier: site.name,
        start_command: site.serve_command,
        # before_start: method(:before_start),
        ping_command: [:tcp, site.serve_host, site.serve_port],
        pid_file: file_path("tmp/static-rails-#{site.name}.pid"),
        lock_file: file_path("tmp/static-rails-#{site.name}.pid.lock"),
        log_file: "/dev/stdout",
        # log_file: file_path("log/static-rails-#{site.name}.log"),
        daemonize_for_me: true
      )
      # end
    end

    def file_path(relative_path)
      Rails.root.join(relative_path).to_s
    end

    def chdir(wd, &blk)
      og = Dir.pwd
      return_value = Bundler.with_unbundled_env {
        Dir.chdir(wd)
        blk.call
      }
      Dir.chdir(og)
      return_value
    end
  end
end
