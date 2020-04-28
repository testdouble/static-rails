require_relative "site"
require_relative "server"

module StaticRails
  class Middleware
    def initialize(app)
      puts "initializing middleware!"
      @app = app
      @servers = {}
    end

    def call(env)
      status, headers, response = @app.call(env)

      initialize_sites_if_necessary!
      start_servers_if_necessary!

      [status, headers, response]
    end

    private

    def initialize_sites_if_necessary!
      return unless @sites.nil?
      @sites = StaticRails.sites.map { |site| Site.new(site) }
    end

    def start_servers_if_necessary!
      @sites.each do |site|
        server = @servers[site] ||= Server.new(@app, site)
        server.start unless server.started?
      end
    end
  end
end
