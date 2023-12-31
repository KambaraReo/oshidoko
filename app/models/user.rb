class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable

  def update_without_current_password(params, *options)
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
      params.delete(:current_password)
      skip_reconfirmation!
      result = update(params, *options)
    else
      current_password = params.delete(:current_password)
      result = if valid_password?(current_password)
                 skip_reconfirmation!
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

  validates :username, presence: true, length: { maximum: 15 }
  validates :introduction, length: { maximum: 200 }

  has_one_attached :icon

  VALID_ICON_TYPES = ['image/jpeg', 'image/jpg', 'image/png'].freeze
  MAX_ICON_SIZE = 1.megabytes

  validate :check_icon_type
  validate :check_icon_size

  has_many :users_members, dependent: :destroy
  has_many :members, through: :users_members

  has_many :posts, dependent: :destroy

  has_many :favorites, dependent: :destroy
  has_many :favorited_posts, through: :favorites, source: :post

  has_many :followers, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :followeds, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  has_many :following_users, through: :followers, source: :followed
  has_many :follower_users, through: :followeds, source: :follower

  # フォローしたときの処理
  def follow(user_id)
    followers.create(followed_id: user_id)
  end

  # フォローを外すときの処理
  def unfollow(user_id)
    followers.find_by(followed_id: user_id).destroy
  end

  # フォローしているか判定
  def following?(user)
    following_users.include?(user)
  end

  has_many :comments, dependent: :destroy

  # ゲストユーザー
  def self.guest
    find_or_create_by!(email: "guest@example.com") do |user|
      user.password = SecureRandom.urlsafe_base64(12)
      user.password_confirmation = user.password
      user.username = "ゲスト"
      user.confirmed_at = Time.now
    end
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
