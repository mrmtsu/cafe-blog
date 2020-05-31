require "rails_helper"

RSpec.describe "投稿登録", type: :request do
  let!(:user) { create(:user) }
  let!(:article) { create(:article, user: user) }

  context "ログインしているユーザーの場合" do
    before do
      get new_article_path
      login_for_request(user)
    end

    context "フレンドリーフォワーディング" do
      it "レスポンスが正常に表示されること" do
        expect(response).to redirect_to new_article_url
      end
    end

    it "有効な投稿データで登録できること" do
      expect {
        post articles_path, params: { article: { name: "店名",
                                                 description: "カフェラテがおいしい",
                                                 place: "場所",
                                                 reference: "https://kitasandocoffee.com/#hero",
                                                 popularity: 5 } }
      }.to change(Article, :count).by(1)
      follow_redirect!
      expect(response).to render_template('articles/show')
    end

    it "無効な投稿データでは登録できないこと" do
      expect {
        post articles_path, params: { article: { name: "",
                                                 description: "カフェラテがおいしい",
                                                 place: "場所",
                                                 reference: "https://kitasandocoffee.com/#hero",
                                                 popularity: 5 } }
      }.not_to change(Article, :count)
      expect(response).to render_template('articles/new')
    end
  end

  context "ログインしていないユーザーの場合" do
    it "ログイン画面にリダイレクトすること" do
      get new_article_path
      expect(response).to have_http_status "302"
      expect(response).to redirect_to login_path
    end
  end
end
