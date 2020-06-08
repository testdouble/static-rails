require_relative "request_forgery_protection_fallback"

module StaticRails
  class GetsCsrfToken
    include RequestForgeryProtectionFallback

    def call(req)
      masked_authenticity_token(req.session)
    end

    private

    def csrf_token_hmac(session, identifier)
      ActionController::RequestForgeryProtection.instance_method(:csrf_token_hmac).bind(self).call(session, identifier)
    end

    def mask_token(raw_token)
      ActionController::RequestForgeryProtection.instance_method(:mask_token).bind(self).call(raw_token)
    end

    def masked_authenticity_token(session, form_options: {})
      ActionController::RequestForgeryProtection.instance_method(:masked_authenticity_token).bind(self).call(session, form_options)
    end

    def global_csrf_token(session)
      ActionController::RequestForgeryProtection.instance_method(:global_csrf_token).bind(self).call(session)
    end

    def real_csrf_token(session)
      ActionController::RequestForgeryProtection.instance_method(:real_csrf_token).bind(self).call(session)
    end

    def xor_byte_strings(s1, s2)
      ActionController::RequestForgeryProtection.instance_method(:xor_byte_strings).bind(self).call(s1, s2)
    end

    def per_form_csrf_tokens
      false
    end
  end
end
