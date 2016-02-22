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
      redirect_to case_workers_admin_allocations_path(allocation_params.merge(tab: params[:tab]))
    else
      render :new
    end
  end

  private

  def summary_from_previous_request?
    params[:claim_ids].present? && (params[:case_worker_id].present? || params[:deallocate])
  end

  def set_summary_values
    @case_worker = CaseWorker.find(params[:case_worker_id]) rescue nil
    @allocated_claims = Claim::BaseClaim.find(params[:claim_ids].reject(&:blank?))
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
    @claims = tab == 'allocated' ? Claim::BaseClaim.caseworker_dashboard_under_assessment : Claim::BaseClaim.submitted_or_redetermination_or_awaiting_written_reasons
    @claims = @claims.order(last_submitted_at: :asc)

    search_claims
    filter_claims
  end

  def tab
    %w(allocated unallocated).include?(params[:tab]) ? params[:tab] : 'unallocated'
  end

  def search_claims(states=nil)
    if params[:search].present?
      @claims = @claims.search(params[:search], states, :case_worker_name_or_email)
    end
  end

  def filter_claims
    filter_by_state_and_type
    filter_by_value
  end

  def filter_by_state_and_type
    case params[:filter]
      when 'redetermination', 'awaiting_written_reasons'
        @claims = @claims.send(params[:filter].to_sym)
      when 'fixed_fee', 'cracked', 'trial', 'guilty_plea'
        @claims = @claims.where{state << %w( redetermination awaiting_written_reasons )}.send(params[:filter].to_sym)
    end
  end

  def filter_by_value
    if params[:claim_value].present? && params[:claim_value] == 'high'
      @claims = @claims.total_greater_than_or_equal_to(Settings.high_value_claim_threshold)
    elsif params[:claim_value].present? && params[:claim_value] == 'low'
      @claims = @claims.total_lower_than(Settings.high_value_claim_threshold)
    end
  end

  def allocation_params
    params.require(:allocation).permit(
     :case_worker_id,
     :deallocate,
     claim_ids: []
    )
  end
end
