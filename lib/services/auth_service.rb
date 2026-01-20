require 'jwt'
require_relative '../models/user'

class AuthService
  ALGORITHM = 'HS256'
  TOKEN_EXPIRATION = 3600

  def initialize(db)
    @db = db
    @secret = ENV['JWT_SECRET'] || 'default_secret_key_change_in_production'
  end

  def authenticate(username, password)
    user = User.find_by_username(@db, username)
    return nil unless user
    return nil unless user.verify_password(password)

    payload = {
      user_id: user.id,
      username: user.username,
      exp: Time.now.to_i + TOKEN_EXPIRATION
    }

    JWT.encode(payload, @secret, ALGORITHM)
  end

  def validate_token(token)
    decoded = JWT.decode(token, @secret, true, { algorithm: ALGORITHM })
    {
      user_id: decoded[0]['user_id'],
      username: decoded[0]['username']
    }
  rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::VerificationError
    nil
  end

  def invalidate_token(token)
  end
end
