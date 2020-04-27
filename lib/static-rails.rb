require_relative "static-rails/error"
require_relative "static-rails/version"
require_relative "static-rails/configuration"

if defined?(Rails) && defined?(Rails::Railtie)
  require "static-rails/railtie"
  # require "static-rails/engine"
end

module StaticRails
  extend Configuration
end
