# == Schema Information
#
# Table name: runners
#
#  id          :integer          not null, primary key
#  token       :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  description :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :runner do
    token "MyString"
  end
end
