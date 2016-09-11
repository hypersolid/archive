FactoryGirl.define do
  factory :broadcast_plugin, class: 'Gazeta::Plugins::Broadcast' do
    live false

    trait :live do
      live true
    end

    trait :with_entries do
      transient do
        entries_count 3
      end

      after(:create) do |broadcast_plugin, evalutor|
        create_list(:broadcast_entry, evalutor.entries_count,
                    extendable: broadcast_plugin)
      end
    end
  end

  factory :broadcast_entry, class: 'Gazeta::Plugins::Broadcasting::Entry' do
    published_at { Time.zone.now }
    body { Faker::Lorem.paragraph }
    author_id { create(:author).id }
    association :broadcasting, factory: :broadcast_plugin
    state 'drafted'
    important false
  end
end
