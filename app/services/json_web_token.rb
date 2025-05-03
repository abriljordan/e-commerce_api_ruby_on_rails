require 'jwt'

# services/json_web_token.rb
class JsonWebToken
  SECRET_KEY = Rails.application.credentials.secret_key_base
  REFRESH_SECRET_KEY = Rails.env.production? ? Rails.application.credentials.refresh_secret_key_base : "development_refresh_secret_key_#{Rails.application.credentials.secret_key_base}"

  def self.encode(payload, exp = 24.hours.from_now)
    raise "Secret key not configured" unless SECRET_KEY

    payload[:exp] = exp.to_i
    ::JWT.encode(payload, SECRET_KEY, "HS256")
  end

  def self.refresh_encode(payload, exp = 7.days.from_now)
    payload[:exp] = exp.to_i
    ::JWT.encode(payload, REFRESH_SECRET_KEY, "HS256")
  end

  def self.decode(token)
    return nil unless SECRET_KEY

    decoded = ::JWT.decode(token, SECRET_KEY, true, { algorithm: "HS256" }).first
    Rails.logger.debug "Decoded JWT Payload: #{decoded.inspect}"
    Rails.logger.debug "Decoded Token: #{decoded}"  # Debugging line

    HashWithIndifferentAccess.new(decoded)
  rescue ::JWT::ExpiredSignature
    Rails.logger.debug "JWT Error: Expired Signature"
    {}
  rescue ::JWT::DecodeError, ::JWT::VerificationError
    Rails.logger.debug "JWT Error: Decode Error or Verification Error"
    {}
  end

  def self.refresh_decode(token)
    decoded = ::JWT.decode(token, REFRESH_SECRET_KEY, true, { algorithm: "HS256" }).first
    HashWithIndifferentAccess.new(decoded)
  rescue ::JWT::ExpiredSignature
    Rails.logger.debug "Refresh Token Error: Expired Signature"
    {}
  rescue ::JWT::DecodeError, ::JWT::VerificationError
    Rails.logger.debug "Refresh Token Error: Decode Error or Verification Error"
    {}
  end
end
