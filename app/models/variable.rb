# == Schema Information
#
# Table name: variables
#
#  id                   :integer          not null, primary key
#  project_id           :integer          not null
#  key                  :string(255)
#  value                :text
#  encrypted_value      :text
#  encrypted_value_salt :string(255)
#  encrypted_value_iv   :string(255)
#

class Variable < ActiveRecord::Base
  belongs_to :project

  validates_presence_of :key
  validates_uniqueness_of :key, scope: :project_id

  attr_encrypted :value, mode: :per_attribute_iv_and_salt, key: GitlabCi::Application.secrets.db_key_base
end
