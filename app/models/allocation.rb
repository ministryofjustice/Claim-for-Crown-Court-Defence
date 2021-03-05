class Allocation
  include ActiveModel::Model
  include ActiveModel::Validations

  # we add 'allocated' into the list of valid states for allocation because
  # that can happen if another caseworker is allocating the claim at the same time.
  # We test for that in allocate_all_claims_or_none!() and fail with a specific
  # error message if that's the case: we don't want to catch it with a generic wrong
  # state error message in claims_in_correct_state_for?(:allocation)
  #
  VALID_STATES_FOR_TRANSITION = {
    allocation: Claims::StateMachine::VALID_STATES_FOR_ALLOCATION + ['allocated'],
    deallocation: Claims::StateMachine::VALID_STATES_FOR_DEALLOCATION,
    reallocation: Claims::StateMachine::VALID_STATES_FOR_DEALLOCATION
  }.freeze

  class << self
    def i18n_scope
      :activerecord
    end
  end

  attr_accessor :current_user, :case_worker_id, :claim_ids, :deallocate, :allocating, :successful_claims, :transaction

  validates :case_worker_id, presence: true, unless: :deallocating?
  validates :claim_ids, presence: true

  def initialize(attributes = {})
    @current_user = attributes[:current_user]
    @case_worker_id = attributes[:case_worker_id]
    @claim_ids = attributes[:claim_ids]&.reject(&:blank?)
    @deallocate = [true, 'true'].include?(attributes[:deallocate])
    @allocating = attributes[:allocating]
    @successful_claims = []
    @transaction = SecureRandom.random_number(9999)
    LogStuff.send(:info, 'Allocation',
                  action: 'allocation',
                  transaction_id: @transaction,
                  allocating_user_id: @current_user&.id,
                  allocating_to_user_id: @case_worker_id,
                  claim_ids: @claim_ids,
                  allocating: @allocating,
                  deallocate: @deallocate,
                  reallocate: !@allocating && !@deallocate) do
      "Start allocation (#{@transaction})"
    end
  end

  def save
    return false unless valid?
    if can_allocate_claims?
      allocate_all_claims_or_none!
    elsif can_deallocate_claims?
      deallocate_claims
    elsif can_reallocate_claims?
      reallocate_claims
    end
    # reallocating is true if not allocating and not deallocating
    errors.empty?
  end

  def claims
    @claims ||= Claim::BaseClaim.active.find(@claim_ids)
  end

  def claims_in_correct_state_for?(new_state)
    claims.each do |claim|
      next if claim.state.in?(VALID_STATES_FOR_TRANSITION[new_state])
      errors.add(:base, "Claim #{claim.id} cannot be transitioned to #{new_state} from #{claim.state}")
    end
    errors[:base].empty?
  end

  def reallocate_claims
    claims.each { |claim| allocate_claim!(claim) }
  end

  def case_worker
    CaseWorker.active.find(@case_worker_id)
  rescue ActiveRecord::ActiveRecordError
    nil
    # deallocation will have a nil case worker id
  end

  private

  def can_reallocate_claims?
    reallocating? && claims_in_correct_state_for?(:reallocation)
  end

  def can_deallocate_claims?
    deallocating? && claims_in_correct_state_for?(:deallocation)
  end

  def can_allocate_claims?
    allocating? && claims_in_correct_state_for?(:allocation)
  end

  def allocate_all_claims_or_none!
    ActiveRecord::Base.transaction do
      claims.each do |claim|
        allocate_or_error_claim! claim
      end

      rollback_all_allocations! if errors.any?
    end
  end

  def allocate_or_error_claim!(claim)
    if claim.case_workers.exists?
      errors.add(:base, "Claim #{claim.case_number} has already been allocated to #{claim.case_workers.first.name}")
    else
      allocate_claim! claim
    end
  rescue StandardError => e
    errors.add(:base, "Claim #{claim.case_number} has errors: #{e.message}")
  end

  def rollback_all_allocations!
    errors.add(:base, 'NO claims were allocated')
    @successful_claims = []
    raise ActiveRecord::Rollback
  end

  def allocating?
    @allocating
  end

  def deallocating?
    @deallocate
  end

  def reallocating?
    !deallocating? && !allocating?
  end

  def deallocate_claims
    claims.each { |claim| deallocate_claim!(claim) }
  end

  def deallocate_claim!(claim)
    claim.deallocate!(audit_attributes)
    successful_claims << claim
  end

  def allocate_claim!(claim)
    LogStuff.send(:info, 'Allocation',
                  action: 'allocating',
                  transaction_id: @transaction,
                  allocating_user_id: @current_user&.id,
                  allocating_to_user_id: @case_worker_id,
                  claim_id: claim.id,
                  allocating: @allocating,
                  deallocate: @deallocate,
                  reallocate: !@allocating && !@deallocate) do
      "Transaction (#{@transaction}) allocating #{claim.id}"
    end

    claim.deallocate!(audit_attributes) if claim.allocated?
    claim.allocate!(audit_attributes)

    claim.case_workers << case_worker
    if claim.case_workers.empty?
      LogStuff.send(:error, 'Allocation',
                    action: 'allocated',
                    transaction_id: @transaction,
                    allocating_user_id: @current_user&.id,
                    allocating_to_user_id: @case_worker_id,
                    claim_id: claim.id,
                    case_workers: claim&.case_workers&.pluck(:id)) do
        "Transaction (#{@transaction}) allocating #{claim.id} failed"
      end

      errors.add(:base, "Allocating Claim #{claim.case_number} to #{case_worker&.name} was unsuccessful")
    else
      LogStuff.send(:info, 'Allocation',
                    action: 'allocated',
                    transaction_id: @transaction,
                    allocating_user_id: @current_user&.id,
                    allocating_to_user_id: @case_worker_id,
                    claim_id: claim.id,
                    case_workers: claim&.case_workers&.pluck(:id)) do
        "Transaction (#{@transaction}) allocated #{claim.id}"
      end
      successful_claims << claim
    end
  end

  def audit_attributes
    author_user = current_user
    subject_user = case_worker&.user
    { author_id: author_user&.id, subject_id: subject_user&.id }
  end
end
