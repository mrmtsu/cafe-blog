class FavoritesController < ApplicationController
  before_action :logged_in_user

  def index
    @favorites = current_user.favorites
  end

  def create
    @article = Article.find(params[:article_id])
    @user = @article.user
    current_user.favorite(@article)
    respond_to do |format|
      format.html { redirect_to request.referrer || root_url }
      format.js
    end
    if @user != current_user
      @user.notifications.create(article_id: @article.id, variety: 1,
                                 from_user_id: current_user.id)
      @user.update_attribute(:notification, true)
    end
  end

  def destroy
    @article = Article.find(params[:article_id])
    current_user.favorites.find_by(article_id: @article.id).destroy
    respond_to do |format|
      format.html { redirect_to request.referrer || root_url }
      format.js
    end
  end
end
