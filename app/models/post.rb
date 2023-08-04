class Post < ApplicationRecord
  validates :title, presence: true, length: { maximum: 30 }
  validates :description, length: { maximum: 400 }
  validates :address, presence: true

  belongs_to :user

  has_many_attached :pictures

  VALID_PICTURE_TYPES = ['image/jpeg', 'image/jpg', 'image/png'].freeze
  MAX_PICTURE_SIZE = 5.megabytes
  MAX_COUNT_OF_PICTURES = 3

  validate :check_pictures_type
  validate :check_pictures_size
  validate :check_pictures_count

  has_many :posts_members, dependent: :destroy
  has_many :members, through: :posts_members

  has_many :favorites, dependent: :destroy

  def favorited?(user)
    favorites.where(user_id: user.id).exists?
  end

  private

  def check_pictures_type
    if pictures.attached? && pictures.any? { |picture| !picture.content_type.in?(VALID_PICTURE_TYPES) }
      valid_types = VALID_PICTURE_TYPES.map { |type| type.split('/').last.upcase }
      errors.add(:pictures, "のファイル形式は#{valid_types.join('、')}である必要があります。")
    end
  end

  def check_pictures_size
    if pictures.attached? && pictures.any? { |picture| picture.blob.byte_size > MAX_PICTURE_SIZE }
      errors.add(:pictures, "のファイルサイズは#{MAX_PICTURE_SIZE / 1.megabyte}MB以下である必要があります。")
    end
  end

  def check_pictures_count
    if pictures.attached? && pictures.size > MAX_COUNT_OF_PICTURES
      errors.add(:pictures, "は#{MAX_COUNT_OF_PICTURES}枚までアップロードできます。")
    end
  end
end
