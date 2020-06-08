require_relative "request_forgery_protection_fallback"

module StaticRails
  class ValidatesCsrfToken
    include RequestForgeryProtectionFallback

    def call(req)
      valid_authenticity_token?(req.session, req.cookies["_csrf_token"])
    end

    private

    [
      :compare_with_global_token,
      :global_csrf_token,
      :csrf_token_hmac,
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
