FactoryGirl.define do
  factory :event, class: Event do
    sequence :description do |n|
      "updated project settings#{n}"
    end

    factory :admin_event do
      is_admin true
    end
  end
end