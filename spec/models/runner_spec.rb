# == Schema Information
#
# Table name: runners
#
#  id         :integer          not null, primary key
#  token      :string(255)
#  public_key :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Runner do
  pending "add some examples to (or delete) #{__FILE__}"
end
