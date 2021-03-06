class Article < ApplicationRecord
  belongs_to :user
  has_many :favorites, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :images, dependent: :destroy
  has_many :logs, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :name, presence: true, length: { maximum: 30 }
  validates :description, length: { maximum: 140 }
  validates :popularity,
            :numericality => {
              :only_interger => true,
              :greater_than_or_equal_to => 1,
              :less_than_or_equal_to => 5
            },
            allow_nil: true

  validate  :image_size

  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to_active_hash :place

  def feed_comment(article_id)
    Comment.where("article_id = ?", article_id)
  end

  def feed_log(article_id)
    Log.where("article_id = ?", article_id)
  end


  private

    def image_size
      if images.size > 5.megabytes
        errors.add(:src, "：5MBより大きい画像はアップロードできません。")
      end
    end
end
