module StaticRails
  class Railtie < ::Rails::Railtie
    # initializer "staticrails.initialize" do |app|
    #   @app = app
    # end

    # config.after_initialize do |app|
    #   @sites = StaticRails.sites.map { |site| Site.new(site) }
    # convert them all to value objects
    # if command isn't running a rails server, do nothing
    # if dev/test start server
    # https://blog.carbonfive.com/2011/02/25/configure-your-gem-the-rails-way-with-railtie/
    # binding.pry
    # end

    unless Rails.env.production?
      config.app_middleware.insert_before 0, Middleware
    end
  end
end
