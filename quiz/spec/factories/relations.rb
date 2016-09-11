FactoryGirl.define do
  factory :email_relation, :class => Relation do
    state "pending"
    request_id { Random.rand(1e6).to_s }
    tournament_id { Tournament.current.id }
  end

  factory :facebook_relation, :class => Relation do
    state "pending"
    request_id "164937970272831_100002993348446"
    tournament_id { Tournament.current.id }
  end
end