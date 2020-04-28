module StaticRails
  class Server
    def initialize(app, site)
      @app = app
      @site = site
    end

    def start
      return if started?
      @pid = spawn_process
      set_at_exit_hook
      nil
    end

    def started?
      return false unless @pid.present?

      begin
        Process.getpgid(@pid)
        true
      rescue Errno::ESRCH
        false
      end
    end

    private

    def spawn_process
      options = {
        in: "/dev/null",
        out: "/dev/stdout",
        err: "/dev/stderr",
        close_others: true,
        chdir: Rails.root.join(@site.source_dir).to_s
      }

      Rails.logger.info "=> Starting #{@site.name} static server"
      Bundler.with_unbundled_env do
        Process.spawn(ENV, @site.serve_command, options).tap do |pid|
          Process.detach(pid)
        end
      end
    end

    def set_at_exit_hook
      return if @at_exit_hook_set
      at_exit do
        return unless started?

        Rails.logger.info "=> Stopping #{@site.name} static server"
        Process.kill("INT", @pid)
      end
      @at_exit_hook_set = true
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
