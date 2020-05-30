FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    sequence(:email) { |n| "example#{n}@example.com" }
    password { "foobar" }
    password_confirmation { "foobar" }
    introduction { "初めまして" }
    sex { "男性" }

    trait :admin do
      admin { true }
    end
  end
end
