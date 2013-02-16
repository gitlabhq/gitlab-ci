# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_oauth_account do
    provider "MyString"
    uid "MyString"
    user
    token "MyString"
    secret "MyString"
    name "MyString"
    link "MyString"
  end
  trait :github do
    provider 'github'
  end
end
