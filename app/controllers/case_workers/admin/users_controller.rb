class CaseWorkers::Admin::UsersController < CaseWorkers::Admin::ApplicationController
  before_action :set_user, only: [:show, :edit, :allocate, :update, :destroy]

  def index
    @users = CaseWorker.all
  end

  def show; end

  def edit; end

  def allocate
    @claims = Claim.all
  end

  def new
    @user = CaseWorker.new
  end

  def create
    @user = CaseWorker.new(user_params)

    if @user.save
      redirect_to case_workers_admin_users_url, notice: 'Case worker successfully created'
    else
      render :new
    end
  end

  def update
    if @user.update(user_params)
      redirect_to case_workers_admin_users_url, notice: 'Case worker successfully updated'
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to case_workers_admin_users_url, notice: 'Case worker deleted'
  end

  private

  def set_user
    @user = CaseWorker.find(params[:id])
  end

  def user_params
    params.require(:case_worker).permit(
     :role,
      user_attributes: [:email, :password, :password_confirmation],
     claim_ids: []
    )
  end
end
