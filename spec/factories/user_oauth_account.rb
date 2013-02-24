# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_oauth_account do
    uid "MyString"
    user
    token "MyString"
    secret "MyString"
    name "MyString"
    link "MyString"
    provider 'github'
  end
end
