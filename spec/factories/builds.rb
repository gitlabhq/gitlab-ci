# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :build do
    ref 'master'
    sha 'HEAD'
  end
end
