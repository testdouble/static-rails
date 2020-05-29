module StaticRails
  class ValidatesCsrfToken
    def call(req)
      valid_authenticity_token?(req.session, req.cookies["_csrf_token"])
    end

    private

    [
      :valid_authenticity_token?,
      :unmask_token,
      :compare_with_real_token,
      :valid_per_form_csrf_token?,
      :xor_byte_strings,
      :real_csrf_token
    ].each do |method|
      define_method method do |*args, **kwargs, &blk|
        ActionController::RequestForgeryProtection.instance_method(method).bind(self).call(*args, **kwargs, &blk)
      end
    end

    def per_form_csrf_tokens
      false
    end
  end
end
