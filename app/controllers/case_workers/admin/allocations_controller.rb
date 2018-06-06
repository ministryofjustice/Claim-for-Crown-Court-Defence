class CaseWorkers::Admin::AllocationsController < CaseWorkers::Admin::ApplicationController
  include PaginationHelpers

  before_action :set_case_workers, only: %i[new create]
  before_action :set_claims, only: %i[new create]
  before_action :set_summary_values, only: [:new], if: :summary_from_previous_request?
  before_action :process_claim_ids, only: [:create], if: :quantity_allocation?

  def new
    @allocation = Allocation.new
  end

  def create
    @allocation = Allocation.new(allocation_params.merge(current_user: current_user))
    if @allocation.save
      redirect_with_feedback(@allocation)
    else
      render :new
    end
  end

  private

  def redirect_with_feedback(allocation)
    flash[:notice] = notification(allocation)
    redirect_to case_workers_admin_allocations_path(tab: tab, scheme: scheme)
  end

  def summary_from_previous_request?
    params[:claim_ids].present? && (params[:case_worker_id].present? || params[:deallocate])
  end

  # TODO: these will also need to be remote API calls, eventually
  # I don't think this is needed any more.
  # def set_summary_values
  #   @case_worker = CaseWorker.active.find(params[:case_worker_id]) rescue nil
  #   @allocated_claims = Claim::BaseClaim.active.find(params[:claim_ids].reject(&:blank?))
  #   params.delete(:case_worker_id)
  #   params.delete(:claim_ids)
  # end

  def quantity_allocation?
    quantity_to_allocate.positive?
  end

  def quantity_to_allocate
    params[:quantity_to_allocate].to_i
  end

  def process_claim_ids
    params[:allocation][:claim_ids] = @claims.first(quantity_to_allocate).map(&:id).map(&:to_s)
  end

  def set_case_workers
    @case_workers = CaseWorkerService.new(current_user: current_user).active
  end

  def set_claims
    @claims = Claims::CaseWorkerClaims.new(current_user: current_user, action: tab, criteria: criteria_params).claims
    add_claim_carousel_info
  end

  def scheme
    %w[agfs lgfs].include?(params[:scheme]) ? params[:scheme] : 'agfs'
  end

  def tab
    %w[allocated unallocated].include?(params[:tab]) ? params[:tab] : 'unallocated'
  end

  def filter
    params[:filter] || 'all'
  end

  def value_band_id
    params[:value_band_id] || 0
  end

  def filter_claims
    @claims = @claims.filter(filter)
  end

  def search_terms
    params[:search]
  end

  def search_claims(states = nil)
    return unless search_terms.present?
    @claims = @claims.search(search_terms, states, :case_worker_name_or_email)
  end

  def sort_and_paginate
    @claims = @claims.sort_using(sort_column, sort_direction).page(current_page).per(page_size)
  end

  def allocation_params
    allocator_params = params.require(:allocation).permit(:case_worker_id, :deallocate, claim_ids: [])
    allocator_params.merge(allocating: is_allocating?)
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
    limit = quantity_allocation? ? quantity_to_allocate : page_size
    { sorting: sort_column, direction: sort_direction, scheme: scheme, filter: filter,
      page: current_page, limit: limit, search: search_terms, value_band_id: value_band_id }
  end
end
