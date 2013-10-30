# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :coverage do
    file "MyString"
    lines "MyString"
    percentage 1.5
  end
end
