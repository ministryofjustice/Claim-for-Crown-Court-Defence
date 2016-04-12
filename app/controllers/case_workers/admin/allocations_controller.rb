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
      render_new_with_feedback(@allocation)
    else
      render :new
    end
  end

  private

  def render_new_with_feedback(allocation)
    flash.now[:notice] = notification(allocation)
    render :new
  end

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
    filter_by_claim_type_and_assessed_state
    search_claims
    filter_claims
    order_claims
  end

  def scheme
    %w(agfs lgfs).include?(params[:scheme]) ? params[:scheme] : 'agfs'
  end

  def tab
    %w(allocated unallocated).include?(params[:tab]) ? params[:tab] : 'unallocated'
  end

  def claim_type
    scheme == 'lgfs' ? Claim::LitigatorClaim : Claim::AdvocateClaim
  end

  def search_claims(states=nil)
    if params[:search].present?
      @claims = @claims.search(params[:search], states, :case_worker_name_or_email)
    end
  end

  def filter_by_claim_type_and_assessed_state
    @claims = tab == 'allocated' ? claim_type.caseworker_dashboard_under_assessment : claim_type.submitted_or_redetermination_or_awaiting_written_reasons
  end

  def filter_claims
    filter_by_state_and_case_type
    filter_by_value
  end

  def filter_by_state_and_case_type
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

  def order_claims
    @claims = @claims.order(last_submitted_at: :asc)
  end


  def allocation_params
    ap = params.require(:allocation).permit(
     :case_worker_id,
     :deallocate,
     claim_ids: []
    )
    ap.merge(allocating: is_allocating?)
  end

  def notification(allocation)
    claims = allocation.successful_claims
    case_worker = allocation.case_worker

    message = "#{claims.size} #{'claim'.pluralize(claims.size)}"
    message = if case_worker
                "#{message} allocated to #{case_worker.name}"
              else
                "#{message} returned to allocation pool"
              end
  end

  def is_allocating?
    params[:commit] == 'Allocate'
  end

end
