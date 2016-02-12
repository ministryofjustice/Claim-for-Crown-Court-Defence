class CaseWorkers::Admin::CaseWorkersController < CaseWorkers::Admin::ApplicationController

  include PasswordHelpers

  before_action :set_case_worker, only: [:show, :edit, :update, :destroy, :change_password, :update_password]

  def index
    @case_workers = CaseWorker.includes(:location).joins(:user)
    @case_workers = @case_workers.where("lower(users.first_name || ' ' || users.last_name) ILIKE :term", term: "%#{params[:search]}%") if params[:search].present?
    @case_workers = @case_workers.order('users.last_name', 'users.first_name')
  end

  def show; end

  def edit; end

  def change_password; end

  def new
    @case_worker = CaseWorker.new
    @case_worker = CaseWorker.new(days_worked: [ 0, 0, 0, 0, 0 ])
    @case_worker.build_user
  end

  def create
    @case_worker = CaseWorker.new(params_with_temporary_password)
    if @case_worker.save
      deliver_reset_password_instructions(@case_worker.user)
      redirect_to case_workers_admin_case_workers_url, notice: 'Case worker successfully created'
    else
      render :new
    end
  end

  def update
    if @case_worker.update(case_worker_params)
      redirect_to case_workers_admin_case_workers_url, notice: 'Case worker successfully updated'
    else
      render :edit
    end
  end

  # NOTE: update_password in PasswordHelper

  def destroy
    @case_worker.destroy
    redirect_to case_workers_admin_case_workers_url, notice: 'Case worker deleted'
  end

  private

  def set_case_worker
    @case_worker = CaseWorker.find(params[:id])
  end

  def case_worker_params
    params.require(:case_worker).permit(
     :location_id,
     :days_worked_0,
     :days_worked_1,
     :days_worked_2,
     :days_worked_3,
     :days_worked_4,
     user_attributes: [:id, :email, :email_confirmation, :current_password, :password, :password_confirmation, :first_name, :last_name],
     claim_ids: [],
     roles: []
    )
  end
end
