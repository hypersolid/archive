FactoryGirl.define do
  factory :ladder do
    position 1
    set_at 1.hour.ago
    score 10000
    combined_score 11000
  end
end