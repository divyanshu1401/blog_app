class Post < ApplicationRecord
  belongs_to :user

  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  has_one_attached :image

  def liked_by?(user)
    likes.exists?(user: user)
  end
end
