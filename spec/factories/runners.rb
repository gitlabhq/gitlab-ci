# == Schema Information
#
# Table name: runners
#
#  id          :integer          not null, primary key
#  token       :string(255)
#  public_key  :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :runner do
    token "MyString"
  end
end
