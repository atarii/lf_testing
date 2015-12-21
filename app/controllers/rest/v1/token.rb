module Rest
  module V1
    class Token
      TTL = 24.hours

      def initialize(au_token = nil)
        @auth_token = au_token
      end

      def authenticate
        $auth_tokens.delete_if { |au_token| au_token[:email] == @auth_token[:email] } unless $auth_tokens.blank?

        error = User.new.do_sign_in @auth_token[:email], @auth_token[:password]
        if error.blank?
          token = SecureRandom.uuid
          $auth_tokens.push(email: @auth_token[:email], token: token, created_at: Time.zone.now)

          { status: true, session: token }
        else
          { status: false, message: error }
        end
      end

      def expired?
        elapsed = Time.zone.now - @auth_token[:created_at]
        remaining = (TTL - elapsed).floor
        remaining <= 0
      end
    end
  end
end
