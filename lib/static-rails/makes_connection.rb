module StaticRails
  class MakesConnection
    def call(host:, port:, timeout:, raise_on_failure: true)
      Socket.tcp(host, port, connect_timeout: timeout)
      true
    rescue Errno::ECONNREFUSED, Errno::EADDRNOTAVAIL => e
      if raise_on_failure
        raise ConnectionFailure.new(e.message)
      else
        false
      end
    end
  end
end
