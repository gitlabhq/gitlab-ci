class Runner < ActiveRecord::Base
  has_many :builds
  has_one :last_build, class_name: 'Build'

  attr_accessible :token, :public_key

  before_validation :set_default_values

  def set_default_values
    self.token = SecureRandom.hex(15) if self.token.blank?
  end
end
