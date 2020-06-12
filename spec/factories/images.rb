FactoryBot.define do
  factory :images do
    src { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec/fixtures/test_article.jpg')) }
    association :article
  end
end
