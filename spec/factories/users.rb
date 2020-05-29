FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    sequence(:email) { |n| "example#{n}@example.com" }
    password { "foobar" }
    password_confirmation { "foobar" }
    introduction { "カフェ巡りが趣味です！よろしくお願いします。" }
    sex { "男性" }
  end
end
