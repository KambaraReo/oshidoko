class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :user_id, uniqueness: { scope: :post_id }
  validates :comment, length: { maximum: 200 }
  validates :rate, presence: true
end
