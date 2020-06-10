require_relative "forked_process_check"

module StaticRails
  class ShouldSkipStartingServers
    def call
      StaticRails.config.dont_start_server_if_port_already_bound &&
        ForkedProcessCheck.forked? &&
        ForkedProcessCheck.original_pid_alive?
    end
  end
end
