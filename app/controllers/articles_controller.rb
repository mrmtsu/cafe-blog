class ArticlesController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user, only: [:edit, :update]
  before_action :set_article, except: [:new, :create]

  def new
    @article = Article.new
    @article.images.new
  end

  def create
    @article = current_user.articles.build(article_params)
    if @article.save
      flash[:success] = "投稿が登録されました！"
      redirect_to article_path(@article)
    else
      render 'articles/new'
    end
  end

  def show
    @article = Article.find(params[:id])
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])
    if @article.update_attributes(article_params)
      flash[:success] = '投稿情報が更新されました！'
      redirect_to @article
    else
      render 'edit'
    end
  end

  def destroy
    @article = Article.find(params[:id])
    if current_user.admin? || current_user?(@article.user)
      @article.destroy
      flash[:success] = "投稿が削除されました"
      redirect_to request.referrer == user_url(@article.user) ? user_url(@article.user) : root_url
    else
      flash[:danger] = "他人の投稿は削除できません"
      redirect_to root_url
    end
  end


  private

    def article_params
      params.require(:article).permit(:name, :description, :place_id, :reference, :popularity, :cafe_memo, images_attributes:  [:src, :_destroy, :id])
    end

    def correct_user
      @article = current_user.articles.find_by(id: params[:id])
      redirect_to root_url if @article.nil?
    end

    def set_article
      @article = Article.find(params[:id])
    end
end
