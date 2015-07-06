class CaseWorkers::Admin::AllocationsController < CaseWorkers::Admin::ApplicationController
  before_action :set_case_workers, only: [:new, :create]
  before_action :set_claims, only: [:new, :create]

  def new
    if params[:case_worker_id].present? && params[:claim_ids].present?
      @case_worker = CaseWorker.find(params[:case_worker_id])
      @allocated_claims = Claim.find(params[:claim_ids].reject(&:blank?))
    end

    @allocation = Allocation.new
  end

  def create
    process_claim_ids

    @allocation = Allocation.new(allocation_params)

    if @allocation.save
      redirect_to case_workers_admin_allocations_path(allocation_params), notice: "Successfully allocated #{@allocation.claim_ids.size} claims"
    else
      render :new
    end
  end

  private

  def process_claim_ids
    if params[:quantity_to_allocate].present? && params[:quantity_to_allocate].to_i.is_a?(Integer)
      quantity_to_allocate = params[:quantity_to_allocate].to_i
      params[:allocation][:claim_ids] = @claims.limit(quantity_to_allocate).map(&:id).map(&:to_s)
    end
  end

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
