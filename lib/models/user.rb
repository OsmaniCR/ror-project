require 'bcrypt'

class User
  attr_reader :id, :username

  def initialize(attributes)
    @id = attributes[:id]
    @username = attributes[:username]
    @password_hash = attributes[:password_hash]
  end

  def self.find_by_username(db, username)
    user_data = db[:users].where(username: username).first
    return nil unless user_data
    new(user_data)
  end

  def verify_password(password)
    BCrypt::Password.new(@password_hash) == password
  end
end
