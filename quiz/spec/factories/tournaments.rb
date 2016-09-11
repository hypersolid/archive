FactoryGirl.define do
  factory :tournament do
    time_limit 10
    starts_at 1.day.ago
    ends_at 7.days.from_now
    best_time_bonus 500
    avg_time_bonus 250
    points_per_second 100
    avg_score 10000
    deploy_average_scoring true
    cost_pence 35
    existing_user_credits 5
    new_user_credits 3
  end
end