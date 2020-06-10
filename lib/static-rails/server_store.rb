require_relative "should_skip_starting_servers"
require_relative "server"

module StaticRails
  class ServerStore
    def self.instance
      @instance ||= new
    end

    def ensure_all_servers_are_started
      return if @should_skip_starting_servers.call

      StaticRails.config.sites.select(&:start_server).each do |site|
        server_for(site).start
      end
    end

    def server_for(site)
      @servers[site] ||= Server.new(site)
    end

    private

    def initialize
      @servers = {}
      @should_skip_starting_servers = ShouldSkipStartingServers.new
    end
  end
end
