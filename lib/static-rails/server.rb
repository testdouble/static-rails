require_relative "waits_for_connection"

module StaticRails
  class Server
    def initialize(site)
      @site = site
      @ready = false
      @waits_for_connection = WaitsForConnection.new
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
        @ready = false
        false
      end
    end

    def wait_until_ready
      return if @ready
      @waits_for_connection.call(@site)
      @ready = true
    end

    private

    def spawn_process
      options = {
        in: "/dev/null",
        out: "/dev/stdout",
        err: "/dev/stderr",
        close_others: true,
        chdir: StaticRails.config.app.root.join(@site.source_dir).to_s
      }

      Rails.logger.info "=> Starting #{@site.name} static server"
      Bundler.with_unbundled_env do
        Process.spawn(ENV, @site.server_command, options).tap do |pid|
          Process.detach(pid)
        end
      end
    end

    def set_at_exit_hook
      return if @at_exit_hook_set
      at_exit do
        if started?
          Rails.logger.info "=> Stopping #{@site.name} static server"
          Process.kill("INT", @pid)
        end
      end
      @at_exit_hook_set = true
    end
  end
end
