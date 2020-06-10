module StaticRails
  class ForkedProcessCheck
    ORIGINAL_PID = Process.pid

    def self.forked?
      Process.pid != ORIGINAL_PID
    end

    def self.original_pid_alive?
      Process.getpgid(ORIGINAL_PID)
      true
    rescue Errno::ESRCH
      false
    end
  end
end
