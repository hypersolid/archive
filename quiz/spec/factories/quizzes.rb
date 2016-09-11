FactoryGirl.define do
  factory :quiz do
    association :tournament
    association :user
  end
end