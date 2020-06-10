require_relative "makes_connection"

module StaticRails
  class WaitsForConnection
    def initialize
      @makes_connection = MakesConnection.new
    end

    def call(site)
      timeout = StaticRails.config.ping_server_timeout
      start = Time.new
      wait_message_logged = false

      loop do
        @makes_connection.call(
          host: site.server_host,
          port: site.server_port,
          timeout: 5
        )
        break
      rescue ConnectionFailure
        elapsed = Time.new - start
        if elapsed > timeout
          raise Error.new("Static site server \"#{site.name}\" failed to start within #{timeout} seconds. You can change the timeout with `StaticRails.config.ping_server_timeout = 42`")
        else
          unless wait_message_logged
            Rails.logger.info "=> Static site server \"#{site.name}\" is not yet accepting connections on #{site.server_host}:#{site.server_port}. Will try to connect for #{timeout} more seconds"
            wait_message_logged = true
          end
          sleep 0.3
        end
      end
    end
  end
end
