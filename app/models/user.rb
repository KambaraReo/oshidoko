class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  validates :username, presence: true, length: { maximum: 15 }
  validates :introduction, length: { maximum: 200 }

  has_one_attached :icon

  VALID_ICON_TYPES = ['image/jpeg', 'image/jpg', 'image/png'].freeze
  MAX_ICON_SIZE = 1.megabytes

  validate :check_icon_type
  validate :check_icon_size

  has_many :users_members, dependent: :destroy
  has_many :members, through: :users_members

  has_many :posts

  has_many :favorites, dependent: :destroy
  has_many :favorited_posts, through: :favorites, source: :post

  def update_without_current_password(params, *options)
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
      params.delete(:current_password)
      result = update(params, *options)
    else
      current_password = params.delete(:current_password)
      result = if valid_password?(current_password)
                 update(params, *options)
               else
                 assign_attributes(params, *options)
                 valid?
                 errors.add(:current_password, current_password.blank? ? :blank : :invalid)
                 false
               end
    end

    clean_up_passwords
    result
  end

  private

  def check_icon_type
    if icon.attached? && !icon.content_type.in?(VALID_ICON_TYPES)
      valid_types = VALID_ICON_TYPES.map { |type| type.split('/').last.upcase }
      errors.add(:icon, "のファイル形式は#{valid_types.join('、')}である必要があります。")
    end
  end

  def check_icon_size
    if icon.attached? && icon.byte_size > MAX_ICON_SIZE
      errors.add(:icon, "のファイルサイズは#{MAX_ICON_SIZE / 1.megabyte}MB以下である必要があります。")
    end
  end
end
