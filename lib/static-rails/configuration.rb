module StaticRails
  module Configuration
    def configure
      yield self
    end

    mattr_accessor :sites
    @@sites = []
  end
end
