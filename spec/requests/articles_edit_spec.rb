require "rails_helper"

RSpec.describe "投稿編集", type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:article) { create(:article, user: user) }

  context "認可されたユーザーの場合" do
    it "レスポンスが正常に表示されること(+フレンドリーフォワーディング)" do
      get edit_article_path(article)
      login_for_request(user)
      expect(response).to redirect_to edit_article_url(article)
      patch article_path(article), params: { article: { name: "店名",
                                                        description: "カフェラテがおいしい",
                                                        place: "大阪",
                                                        reference: "https://kitasandocoffee.com/#hero",
                                                        popularity: 5 } }
      redirect_to article
      follow_redirect!
      expect(response).to render_template('articles/show')
    end
  end

  context "ログインしていないユーザーの場合" do
    it "ログイン画面にリダイレクトすること" do
      get edit_article_path(article)
      expect(response).to have_http_status "302"
      expect(response).to redirect_to login_path
      patch article_path(article), params: { article: { name: "店名",
                                                        description: "カフェラテがおいしい",
                                                        place: "大阪",
                                                        reference: "https://kitasandocoffee.com/#hero",
                                                        popularity: 5 } }
      expect(response).to have_http_status "302"
      expect(response).to redirect_to login_path
    end
  end

  context "別アカウントのユーザーの場合" do
    it "ホーム画面にリダイレクトすること" do
      login_for_request(other_user)
      get edit_article_path(article)
      expect(response).to have_http_status "302"
      expect(response).to redirect_to root_path
      patch article_path(article), params: { article: { name: "店名",
                                                        description: "カフェラテがおいしい",
                                                        place: "大阪",
                                                        reference: "https://kitasandocoffee.com/#hero",
                                                        popularity: 5 } }
      expect(response).to have_http_status "302"
      expect(response).to redirect_to root_path
    end
  end
end
