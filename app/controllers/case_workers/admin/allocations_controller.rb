class CaseWorkers::Admin::AllocationsController < CaseWorkers::Admin::ApplicationController
  include PaginationHelpers

  before_action :set_case_workers, only: [:new, :create]
  before_action :set_claims, only: [:new, :create]
  before_action :set_summary_values, only: [:new], if: :summary_from_previous_request?
  before_action :process_claim_ids, only: [:create], if: :quantity_allocation?

  helper_method :allocation_filters_for_scheme

  def new
    @allocation = Allocation.new
  end

  def create
    @allocation = Allocation.new(allocation_params.merge(current_user: current_user))
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
    @case_worker = CaseWorker.active.find(params[:case_worker_id]) rescue nil
    @allocated_claims = Claim::BaseClaim.active.find(params[:claim_ids].reject(&:blank?))
    params.delete(:case_worker_id)
    params.delete(:claim_ids)
  end

  def quantity_allocation?
    params[:quantity_to_allocate].present? && params[:quantity_to_allocate].to_i.is_a?(Integer)
  end

  def process_claim_ids
    quantity_to_allocate = params[:quantity_to_allocate].to_i
    params[:allocation][:claim_ids] = @claims.page(current_page).per(page_size).limit(quantity_to_allocate).map(&:id).map(&:to_s)
  end

  def set_case_workers
    @case_workers = CaseWorkerService.new(current_user: current_user).active
  end

  def set_claims
    @claims = Claims::CaseWorkerClaims.new(current_user: current_user, action: tab, criteria: criteria_params).claims

    unless @claims.remote?
      filter_claims
      search_claims
      sort_and_paginate
    end

    set_claim_carousel_info
  end

  def scheme
    %w(agfs lgfs).include?(params[:scheme]) ? params[:scheme] : 'agfs'
  end

  def tab
    %w(allocated unallocated).include?(params[:tab]) ? params[:tab] : 'unallocated'
  end

  def filter
    params[:filter] || 'all'
  end

  def filter_claims
    @claims = @claims.filter(filter)
  end

  def search_terms
    params[:search]
  end

  def search_claims(states=nil)
    if search_terms.present?
      @claims = @claims.search(search_terms, states, :case_worker_name_or_email)
    end
  end

  def sort_and_paginate
    @claims = @claims.sort(sort_column, sort_direction).page(current_page).per(page_size)
  end

  def allocation_params
    ap = params.require(:allocation).permit(:case_worker_id, :deallocate, claim_ids: [])
    ap.merge(allocating: is_allocating?)
  end

  def notification(allocation)
    claims = allocation.successful_claims
    case_worker = allocation.case_worker
    message = "#{claims.size} #{'claim'.pluralize(claims.size)}"

    if case_worker
      "#{message} allocated to #{case_worker.name}"
    else
      "#{message} returned to allocation pool"
    end
  end

  def is_allocating?
    params[:commit] == 'Allocate'
  end

  def allocation_filters_for_scheme(scheme)
    if scheme == 'agfs'
      %w{ all fixed_fee cracked trial guilty_plea redetermination awaiting_written_reasons }
    elsif scheme == 'lgfs'
      %w{ all fixed_fee graduated_fees interim_fees warrants interim_disbursements risk_based_bills redetermination awaiting_written_reasons }
    else
      []
    end
  end

  def default_page_size
    25
  end

  def sort_column
    'last_submitted_at'
  end

  def sort_direction
    'asc'
  end

  def criteria_params
    {sorting: sort_column, direction: sort_direction, scheme: scheme, filter: filter, page: current_page, limit: page_size, search: search_terms}
  end
end
