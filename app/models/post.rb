class Post < ApplicationRecord

  before_create :prefix_image_key

  belongs_to :user

  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  has_one_attached :image

  def liked_by?(user)
    likes.exists?(user: user)
  end

  def prefix_image_key
    if image.attached? && !image.blob.key.start_with?('uploads/')
      image.blob.update(key: "uploads/#{image.blob.key}")
    end
  end
end
