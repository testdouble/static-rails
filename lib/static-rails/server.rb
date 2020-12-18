require_relative "makes_connection"
require_relative "waits_for_connection"

module StaticRails
  class Server
    def initialize(site)
      @site = site
      @ready = false
      @warned_about_skipping_server_start = false
      @makes_connection = MakesConnection.new
      @waits_for_connection = WaitsForConnection.new
    end

    def start
      return if started?
      return if skip_start?

      @pid = spawn_process
      set_at_exit_hook
      nil
    end

    def wait_until_ready
      return if @ready
      return if skip_start?

      @waits_for_connection.call(@site)
      @ready = true
    end

    private

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

    def skip_start?
      return unless StaticRails.config.dont_start_server_if_port_already_bound

      @makes_connection.call(
        host: @site.server_host,
        port: @site.server_port,
        timeout: 0.2,
        raise_on_failure: false
      ).tap do |connection_made|
        if connection_made && !@warned_about_skipping_server_start
          Rails.logger.info "=> SKIPPING starting #{@site.name} server, because a process is already accepting requests at #{@site.server_host}:#{@site.server_port}"
          @warned_about_skipping_server_start = true
        end
      end
    end

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
        Process.spawn(@site.env, @site.server_command, options).tap do |pid|
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
