# == Schema Information
#
# Table name: variables
#
#  id                   :integer          not null, primary key
#  project_id           :integer          not null
#  key                  :string(255)
#  value                :text
#  encrypted_value      :string(255)
#  encrypted_value_salt :string(255)
#  encrypted_value_iv   :string(255)
#

class Variable < ActiveRecord::Base
  belongs_to :project

  attr_encrypted :value, mode: :per_attribute_iv_and_salt, key: GitlabCi::Application.config.secret_key_base
end
