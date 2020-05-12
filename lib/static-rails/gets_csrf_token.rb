module StaticRails
  class GetsCsrfToken
    def call(req)
      masked_authenticity_token(req.session)
    end

    private

    def real_csrf_token(session)
      ActionController::RequestForgeryProtection.instance_method(:real_csrf_token).bind(self).call(session)
    end

    def masked_authenticity_token(session, form_options: {})
      ActionController::RequestForgeryProtection.instance_method(:masked_authenticity_token).bind(self).call(session, form_options)
    end

    def xor_byte_strings(s1, s2)
      ActionController::RequestForgeryProtection.instance_method(:xor_byte_strings).bind(self).call(s1, s2)
    end

    def per_form_csrf_tokens
      false
    end
  end
end
