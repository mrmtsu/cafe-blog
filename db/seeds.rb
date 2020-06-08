User.create!(name:  "山田 太郎",
             email: "sample@example.com",
             password:              "foobar",
             password_confirmation: "foobar",
             admin: true)

99.times do |n|
name  = Faker::Name.name
email = "sample-#{n+1}@example.com"
password = "password"
User.create!(name:  name,
             email: email,
             password:              password,
             password_confirmation: password)
end

10.times do |n|
  Article.create!(name: "カフェラテ",
                  description: "カフェラテが美味しい",
                  place_id: 1,
                  reference: "https://kitasandocoffee.com/#hero",
                  popularity: 5,
                  cafe_memo: "またいきたい！",
                  user_id: 1,
                  images_attributes: [
                                      { src: open("#{Rails.root}/public/images/top.jpeg")}
                  ])
  article = Article.first
  Log.create!(article_id: article.id,
              content: article.cafe_memo)
end

# リレーションシップ
users = User.all
user  = users.first
following = users[2..50]
followers = users[3..40]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }
