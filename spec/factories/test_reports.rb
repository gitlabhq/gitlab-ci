# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :report_files do
    testClass "MyString"
    title "MyString"
    duration 1.5
    description "MyString"
    status "MyText"
  end
end
