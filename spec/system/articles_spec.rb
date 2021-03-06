require 'rails_helper'

RSpec.describe "Articles", type: :system do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:article) { create(:article, :images, user: user) }
  let!(:comment) { create(:comment, user_id: user.id, article: article) }
  let!(:log) { create(:log, article: article) }

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

    context "ログ登録＆削除" do
      context "投稿詳細ページから" do
        it "自分の投稿に対するログ登録＆削除が正常に完了すること" do
          login_for_system(user)
          visit article_path(article)
          fill_in "log_content", with: "次はカフェラテもいいかも"
          click_button "ログ追加"
          within find("#log-#{Log.first.id}") do
            expect(page).to have_selector 'span', text: "#{article.logs.count}回目"
            expect(page).to have_selector 'span',
                                          text: %Q(#{Log.last.created_at.strftime("%Y/%m/%d(%a)")})
            expect(page).to have_selector 'span', text: '次はカフェラテもいいかも'
          end
          expect(page).to have_content "カフェログを追加しました！"
          click_link "削除", href: log_path(Log.first)
          expect(page).to have_content "カフェログを削除しました"
        end

        it "別ユーザーの投稿ログにはログ登録フォームが無いこと" do
          login_for_system(other_user)
          visit article_path(article)
          expect(page).not_to have_button "作る"
        end
      end

      context "トップページから" do
        it "自分の投稿に対するログ登録が正常に完了すること" do
          login_for_system(user)
          visit root_path
          fill_in "log_content", with: "次はカフェラテもいいかも"
          click_button "追加"
          expect(Log.first.content).to eq '次はカフェラテもいいかも'
          expect(page).to have_content "カフェログを追加しました！"
        end

        it "別ユーザーの投稿にはログ登録フォームがないこと" do
          create(:article, :images, user: other_user)
          login_for_system(user)
          user.follow(other_user)
          visit root_path
          within find("#article-#{Article.first.id}") do
            expect(page).not_to have_button "作る"
          end
        end
      end

      context "プロフィールページから" do
        it "自分の投稿に対するログ登録が正常に完了すること" do
          login_for_system(user)
          visit user_path(user)
          fill_in "log_content", with: "次はカフェラテもいいかも"
          click_button "追加"
          expect(Log.first.content).to eq '次はカフェラテもいいかも'
          expect(page).to have_content "カフェログを追加しました！"
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

  context "検索機能" do
    context "ログインしている場合" do
      before do
        login_for_system(user)
        visit root_path
      end

      it "ログイン後のトップページに検索窓が表示されていること" do
        expect(page).to have_css 'form#article_search'
        visit root_path
      end

      it "検索ワードを入れずに検索ボタンを押した場合、投稿一覧が表示されること" do
        fill_in 'q_name_cont', with: ''
        click_button '検索'
        expect(page).to have_css 'h3', text: "投稿一覧"
        within find('.articles') do
          expect(page).to have_css 'li', count: Article.count
        end
      end
    end

    context "ログインしていない場合" do
      it "検索窓が表示されないこと" do
        visit root_path
        expect(page).not_to have_css 'form#article_search'
      end
    end
  end
end
