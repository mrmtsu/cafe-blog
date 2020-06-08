FactoryBot.define do
  factory :log do
    content { "次はカフェラテもいいかも" }
    association :article
  end
end
