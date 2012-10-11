require 'digest/sha1'

class User < ActiveRecord::Base
  attr_accessible :email, :password

  def self.authenticate(email, pass)
    user = User.where(email: email).last

    if user && user.valid_password?(pass)
      user
    else
      nil
    end
  end

  def self.encrypt(pass)
    Digest::SHA1.hexdigest pass
  end

  def valid_password? pass
    self.password == User.encrypt(pass)
  end
end
