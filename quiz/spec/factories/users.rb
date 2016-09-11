FactoryGirl.define do
  factory :user do
    email "user@example.com"
    admin false 
    name "John Doe"
    password "quizquiz"
    credits 0
    facebook_uid 1206903360
  end

  factory :admin_user, :parent => :user do
    email "admin@example.com"
    admin true
  end
end