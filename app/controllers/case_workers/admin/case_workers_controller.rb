class CaseWorkers::Admin::CaseWorkersController < CaseWorkers::Admin::ApplicationController
  before_action :set_case_worker, only: [:show, :edit, :allocate, :update, :destroy]

  def index
    @case_workers = CaseWorker.all
  end

  def show

  end

  def edit

  end

  def allocate
    @claims = Claim.unscope(:includes).includes( [ {:defendants => :representation_orders}, :advocate, :court, :case_workers ] ).non_draft.order(created_at: :asc)
  end

  def new
    @case_worker = CaseWorker.new
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
      user_attributes: [:email, :password, :password_confirmation, :first_name, :last_name],
     claim_ids: []
    )
  end
end
