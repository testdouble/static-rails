require_relative "server"

module StaticRails
  class ServerStore
    def self.instance
      @instance ||= new
    end

    def ensure_all_servers_are_started
      StaticRails.config.sites.select(&:start_server).each do |site|
        server_for(site).start
      end
    end

    def server_for(site)
      @servers[site] ||= Server.new(site)
    end

    def ensure_servers_are_up
      @servers.values.each(&:start)
    end

    private

    def initialize
      @servers = {}
    end
  end
end
