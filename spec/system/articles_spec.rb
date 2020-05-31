require 'rails_helper'

RSpec.describe "Articles", type: :system do
  let!(:user) { create(:user) }
  let!(:article) { create(:article, user: user) }

  describe "投稿登録ページ" do
    before do
      login_for_system(user)
      visit new_article_path
    end

    context "ページレイアウト" do
      it "「投稿登録」の文字列が存在すること" do
        expect(page).to have_content '投稿登録'
      end

      it "正しいタイトルが表示されること" do
        expect(page).to have_title full_title('投稿登録')
      end

      it "入力部分に適切なラベルが表示されること" do
        expect(page).to have_content '店名'
        expect(page).to have_content '説明'
        expect(page).to have_content '場所'
        expect(page).to have_content 'URL'
        expect(page).to have_content 'おすすめ度 [1~5]'
        expect(page).to have_content 'カフェメモ'
      end
    end

    context "投稿登録処理" do
      it "有効な情報で投稿登録を行うと投稿登録成功のフラッシュが表示されること" do
        fill_in "店名", with: "店名"
        fill_in "説明", with: "カフェラテがおいしい"
        fill_in "場所", with: "大阪"
        fill_in "URL", with: "https://kitasandocoffee.com/#hero"
        fill_in "おすすめ度", with: 5
        click_button "登録する"
        expect(page).to have_content "投稿が登録されました！"
      end

      it "無効な情報で投稿登録を行うと投稿登録失敗のフラッシュが表示されること" do
        fill_in "店名", with: ""
        fill_in "説明", with: "カフェラテがおいしい"
        fill_in "場所", with: "大阪"
        fill_in "URL", with: "https://kitasandocoffee.com/#hero"
        fill_in "おすすめ度", with: 5
        click_button "登録する"
        expect(page).to have_content "店名を入力してください"
      end
    end
  end

  describe "投稿詳細ページ" do
    context "ページレイアウト" do
      before do
        login_for_system(user)
        visit article_path(article)
      end

      it "正しいタイトルが表示されること" do
        expect(page).to have_title full_title("#{article.name}")
      end

      it "投稿情報が表示されること" do
        expect(page).to have_content article.name
        expect(page).to have_content article.description
        expect(page).to have_content article.place
        expect(page).to have_content article.reference
        expect(page).to have_content article.popularity
      end
    end
  end

  describe "投稿編集ページ" do
    before do
      login_for_system(user)
      visit article_path(article)
      click_link "編集"
    end

    context "ページレイアウト" do
      it "正しいタイトルが表示されること" do
        expect(page).to have_title full_title('投稿情報の編集')
      end

      it "入力部分に適切なラベルが表示されること" do
        expect(page).to have_content '店名'
        expect(page).to have_content '説明'
        expect(page).to have_content '場所'
        expect(page).to have_content 'URL'
        expect(page).to have_content 'おすすめ度 [1~5]'
      end
    end

    context "投稿の更新処理" do
      it "有効な更新" do
        fill_in "店名", with: "編集：店名"
        fill_in "説明", with: "編集：カフェラテがおいしい"
        fill_in "場所", with: "編集：大阪"
        fill_in "URL", with: "https://kitasandocoffee.com/#hero"
        fill_in "おすすめ度", with: 1
        click_button "更新する"
        expect(page).to have_content "投稿情報が更新されました！"
        expect(article.reload.name).to eq "編集：店名"
        expect(article.reload.description).to eq "カフェラテがおいしい"
        expect(article.reload.place).to eq 0
        expect(article.reload.reference).to eq "https://kitasandocoffee.com/#hero"
        expect(article.reload.popularity).to eq 1
      end

      it "無効な更新" do
        fill_in "店名", with: ""
        click_button "更新する"
        expect(page).to have_content '店名を入力してください'
        expect(article.reload.name).not_to eq ""
      end
    end
  end
end
