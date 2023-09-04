class Contact < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze

  validates :name, presence: true, length: { maximum: 20 }
  validates :email, presence: true, length: { maximum: 30 }, format: { with: VALID_EMAIL_REGEX }
  validates :content, presence: true, length: { maximum: 800 }
end
