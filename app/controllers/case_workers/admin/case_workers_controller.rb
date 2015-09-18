class CaseWorkers::Admin::CaseWorkersController < CaseWorkers::Admin::ApplicationController
  before_action :set_case_worker, only: [:show, :edit, :allocate, :update, :destroy, :change_password, :update_password]

  def index
    @case_workers = CaseWorker.joins(:user).order('users.last_name', 'users.first_name')
  end

  def show; end

  def edit; end

  def change_password; end

  def allocate
    @claims = Claim.unscope(:includes).includes( [ {:defendants => :representation_orders}, :advocate, :court, :case_workers ] ).non_draft.order(created_at: :asc)
  end

  def new
    @case_worker = CaseWorker.new
    @case_worker = CaseWorker.new(days_worked: [ 0, 0, 0, 0, 0 ])
    @case_worker.build_user
  end

  def create
    @case_worker = CaseWorker.new(case_worker_params)

    if @case_worker.save
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

  def update_password
    password_params = case_worker_params.slice(:user_attributes)
    password_params[:user_attributes].delete(:email)
    password_params[:user_attributes].delete(:first_name)
    password_params[:user_attributes].delete(:last_name)

    user = @case_worker.user
    if user.update_with_password(password_params[:user_attributes])
      sign_in(user, bypass: true)
      redirect_to case_workers_admin_case_worker_path(@case_worker), notice: 'Password successfully updated'
    else
      render :change_password
    end
  end

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
     :role,
     :location_id,
     :days_worked_0,
     :days_worked_1,
     :days_worked_2,
     :days_worked_3,
     :days_worked_4,
     :approval_level,
     user_attributes: [:id, :email, :current_password, :password, :password_confirmation, :first_name, :last_name],
     claim_ids: []
    )
  end
end
