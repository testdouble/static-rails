module StaticRails
  module RequestForgeryProtectionFallback
    def method_missing(method_name, *args, **kwargs, &blk)
      if respond_to?(method_name)
        ActionController::RequestForgeryProtection.instance_method(method_name).bind(self).call(*args, **kwargs, &blk)
      else
        super
      end
    end

    def respond_to?(method_name, *args)
      ActionController::RequestForgeryProtection.instance_method(method_name) || super
    end

    def respond_to_missing?(method_name, *args)
      ActionController::RequestForgeryProtection.instance_method(method_name) || super
    end
  end
end
