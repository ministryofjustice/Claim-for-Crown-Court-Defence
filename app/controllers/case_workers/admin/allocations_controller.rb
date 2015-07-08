class CaseWorkers::Admin::AllocationsController < CaseWorkers::Admin::ApplicationController
  before_action :set_case_workers, only: [:new, :create]
  before_action :set_claims, only: [:new, :create]
  before_action :set_summary_values, only: [:new], if: :summary_from_previous_request?
  before_action :process_claim_ids, only: [:create], if: :quantity_allocation?

  def new
    add_breadcrumb 'Dashboard', case_workers_root_path
    add_breadcrumb 'Allocations', case_workers_admin_allocations_path

    @allocation = Allocation.new
  end

  def create
    @allocation = Allocation.new(allocation_params)

    if @allocation.save
      redirect_to case_workers_admin_allocations_path(allocation_params.merge(tab: params[:tab])), notice: "Successfully allocated #{@allocation.claim_ids.size} claims"
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
    params.delete(:case_worker_id)
    params.delete(:claim_ids)
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
    @claims = tab == 'allocated' ? Claim.caseworker_dashboard_under_assessment : Claim.submitted
    @claims = @claims.order(submitted_at: :asc)
    filter_claims
  end

  def tab
    %w(allocated unallocated).include?(params[:tab]) ? params[:tab] : 'unallocated'
  end

  def filter_claims
    if ['fixed_fee', 'cracked', 'trial', 'guilty_plea'].include?(params[:filter])
      @claims = @claims.send(params[:filter].to_sym)
    end

    if params[:high_value].present? && params[:high_value] == 'true'
      @claims = @claims.total_greater_than_or_equal_to(Settings.high_value_claim_threshold)
    end
  end

  def allocation_params
    params.require(:allocation).permit(
     :case_worker_id,
     claim_ids: []
    )
  end
end
