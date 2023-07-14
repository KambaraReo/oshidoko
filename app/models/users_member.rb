class UsersMember < ApplicationRecord
  belongs_to :user
  belongs_to :member
end
