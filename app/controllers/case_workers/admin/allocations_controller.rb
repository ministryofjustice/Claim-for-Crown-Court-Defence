class CaseWorkers::Admin::AllocationsController < CaseWorkers::Admin::ApplicationController
  before_action :set_case_workers, only: [:new, :create]
  before_action :set_claims, only: [:new, :create]

  def new
    @allocation = Allocation.new
  end

  def create
    @allocation = Allocation.new(allocation_params)

    if @allocation.save
      redirect_to case_workers_admin_allocations_path, notice: "Successfully allocated #{@allocation.claim_ids.size} claims"
    else
      render :new
    end
  end

  private

  def set_case_workers
    @case_workers = CaseWorker.all
  end

  def set_claims
    @claims = Claim.submitted
  end

  def allocation_params
    params.require(:allocation).permit(
     :case_worker_id,
     claim_ids: []
    )
  end
end
