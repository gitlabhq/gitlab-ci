FactoryGirl.define do
  factory :job do
    name 'rspec'
    commands 'bundle exec rspec spec'

    factory :deploy_job do
      job_type :deploy
    end
  end
end
