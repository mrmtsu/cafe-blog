require "rails_helper"

RSpec.describe "StaticPages", type: :system do
  describe "トップページ" do
    context "ページ全体" do
      before do
        visit root_path
      end

      it "CAFE LOGの文字列が存在することを確認" do
        expect(page).to have_content 'CAFE LOG'
      end

      it "正しいタイトルが表示されることを確認" do
        expect(page).to have_title full_title
      end
    end
  end

  describe "ヘルプページ" do
    before do
      visit about_path
    end

    it "ABOUTの文字列が存在することを確認" do
      expect(page).to have_content 'ABOUT'
    end

    it "正しいタイトルが表示されることを確認" do
      expect(page).to have_title full_title('ABOUT')
    end
  end

  describe "TERMSページ" do
    before do
      visit use_of_terms_path
    end

    it "TERMSの文字列が表示されることを確認" do
      expect(page).to have_content 'TERMS'
    end

    it "正しいタイトルが表示されることを確認" do
      expect(page).to have_title full_title('Terms of service')
    end
  end
end
