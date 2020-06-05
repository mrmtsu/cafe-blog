FactoryBot.define do
  factory :comment do
    user_id { 1 }
    content { "美味しかった。" }
    association :article
  end
end
