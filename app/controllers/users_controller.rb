class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def index
  end

  def show
    @user = current_user
  end
end
