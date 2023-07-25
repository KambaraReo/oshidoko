class Post < ApplicationRecord
  validates :title, presence: true, length: { maximum: 30 }
  validates :description, length: { maximum: 400 }
  validates :address, presence: true

  belongs_to :user

  has_one_attached :picture
  has_many :posts_members, dependent: :destroy
  has_many :members, through: :posts_members
end
