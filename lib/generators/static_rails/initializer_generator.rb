module StaticRails
  module Generators
    class InitializerGenerator < ::Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates a sample static-rails initializer."
      def copy_initializer
        copy_file "static.rb", "config/initializers/static.rb"
      end
    end
  end
end
