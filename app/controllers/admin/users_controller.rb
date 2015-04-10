class Admin::UsersController < Admin::ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.all
  end

  def show; end

  def edit; end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to admin_users_url, notice: 'User successfully created'
    else
      render :new
    end
  end

  def update
    if @user.update(user_params)
      redirect_to admin_users_url, notice: 'User successfully updated'
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_url, notice: 'User deleted'
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
     :email,
     :password,
     :password_confirmation,
     :role
    )
  end
end
