class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :username, presence: true, length: { maximum: 15 }

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
end
