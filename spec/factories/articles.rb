FactoryBot.define do
  factory :article do
    name { "ラテアート" }
    description { "カフェラテがおいしい" }
    place_id { 1 }
    reference { "https://kitasandocoffee.com/#hero" }
    popularity { 5 }
    association :user
    created_at { Time.current }
  end

  trait :yesterday do
    created_at { 1.day.ago }
  end

  trait :one_week_ago do
    created_at { 1.week.ago }
  end

  trait :one_month_ago do
    created_at { 1.month.ago }
  end

  trait :images do
    images_attributes {
                        [
                          { src: Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec/fixtures/test_article.jpg')) }
                        ]
    }
  end
end
