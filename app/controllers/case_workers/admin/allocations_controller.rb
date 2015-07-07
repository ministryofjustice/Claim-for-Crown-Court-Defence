class CaseWorkers::Admin::AllocationsController < CaseWorkers::Admin::ApplicationController
  before_action :set_case_workers, only: [:new, :create]
  before_action :set_claims, only: [:new, :create]
  before_action :set_summary_values, only: [:new], if: :summary_from_previous_request?
  before_action :process_claim_ids, only: [:create], if: :quantity_allocation?

  def new
    @allocation = Allocation.new
  end

  def create
    @allocation = Allocation.new(allocation_params)

    if @allocation.save
      redirect_to case_workers_admin_allocations_path(allocation_params), notice: "Successfully allocated #{@allocation.claim_ids.size} claims"
    else
      render :new
    end
  end

  private

  def summary_from_previous_request?
    params[:case_worker_id].present? && params[:claim_ids].present?
  end

  def set_summary_values
    @case_worker = CaseWorker.find(params[:case_worker_id])
    @allocated_claims = Claim.find(params[:claim_ids].reject(&:blank?))
  end

  def quantity_allocation?
    params[:quantity_to_allocate].present? && params[:quantity_to_allocate].to_i.is_a?(Integer)
  end

  def process_claim_ids
    quantity_to_allocate = params[:quantity_to_allocate].to_i
    params[:allocation][:claim_ids] = @claims.limit(quantity_to_allocate).map(&:id).map(&:to_s)
  end

  def set_case_workers
    @case_workers = CaseWorker.all
  end

  def set_claims
    @claims = Claim.submitted

    if ['fixed_fee', 'cracked', 'trial', 'guilty_plea'].include?(params[:filter])
      @claims = @claims.send(params[:filter].to_sym)
    end
  end

  def allocation_params
    params.require(:allocation).permit(
     :case_worker_id,
     claim_ids: []
    )
  end
end
