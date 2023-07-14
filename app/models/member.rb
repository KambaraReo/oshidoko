class Member < ApplicationRecord
  has_many :users_members
  has_many :users, through: :users_members
end
