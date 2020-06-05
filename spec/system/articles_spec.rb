require 'rails_helper'

RSpec.describe "Articles", type: :system do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:article) { create(:article, user: user) }
  let!(:image) { create(:image, article: article) }
  let!(:comment) { create(:comment, user_id: user.id, article: article) }

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
        expect(page).to have_content '画像'
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
        select "北海道", from: "article[place_id]"
        fill_in "URL", with: "https://kitasandocoffee.com/#hero"
        fill_in "おすすめ度", with: 5
        attach_file "article[images_attributes][0][src]", "#{Rails.root}/spec/fixtures/test_article.jpg"
        click_button "登録する"
        expect(page).to have_content "投稿が登録されました！"
      end

      it "無効な情報で投稿登録を行うと投稿登録失敗のフラッシュが表示されること" do
        fill_in "店名", with: ""
        fill_in "説明", with: "カフェラテがおいしい"
        select "北海道", from: "article[place_id]"
        fill_in "URL", with: "https://kitasandocoffee.com/#hero"
        fill_in "おすすめ度", with: 5
        attach_file "article[images_attributes][0][src]", "#{Rails.root}/spec/fixtures/test_article.jpg"
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
        expect(page).to have_content article.place.name
        expect(page).to have_content article.reference
        expect(page).to have_content article.popularity
      end
    end

    context "コメントの登録＆削除" do
      it "自分の投稿に対するコメントの登録＆削除が正常に完了すること" do
        login_for_system(user)
        visit article_path(article)
        fill_in "comment_content", with: "今日の味付けは大成功"
        click_button "コメント"
        within find("#comment-#{Comment.last.id}") do
          expect(page).to have_selector 'span', text: user.name
          expect(page).to have_selector 'span', text: '今日の味付けは大成功'
        end
        expect(page).to have_content "コメントを追加しました！"
        click_link "削除", href: comment_path(Comment.last)
        expect(page).not_to have_selector 'span', text: '今日の味付けは大成功'
        expect(page).to have_content "コメントを削除しました"
      end

      it "別ユーザーの投稿のコメントには削除リンクが無いこと" do
        login_for_system(other_user)
        visit article_path(article)
        within find("#comment-#{comment.id}") do
          expect(page).to have_selector 'span', text: user.name
          expect(page).to have_selector 'span', text: comment.content
          expect(page).not_to have_link '削除', href: article_path(article)
        end
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
        select "北海道", from: "article[place_id]"
        fill_in "URL", with: "https://kitasandocoffee.com/#hero"
        fill_in "おすすめ度", with: 1
        attach_file "article[images_attributes][0][src]", "#{Rails.root}/spec/fixtures/test_article2.jpg"
        click_button "更新する"
        expect(page).to have_content "投稿情報が更新されました！"
        expect(article.reload.name).to eq "編集：店名"
        expect(article.reload.description).to eq "編集：カフェラテがおいしい"
        expect(article.reload.place.name).to eq "北海道"
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
