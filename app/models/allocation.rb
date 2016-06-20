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
    deallocation: Claims::StateMachine::VALID_STATES_FOR_DEALLOCATION + ['allocated'],
    reallocation: Claims::StateMachine::VALID_STATES_FOR_DEALLOCATION + ['allocated'],
  }

  class << self
    def i18n_scope
      :activerecord
    end
  end

  attr_accessor :case_worker_id, :claim_ids, :claims, :deallocate, :allocating, :successful_claims

  validates :case_worker_id, presence: true, unless: :deallocating?
  validates :claim_ids, presence: true


  def initialize(attributes = {})
    @case_worker_id = attributes[:case_worker_id]
    @claim_ids = attributes[:claim_ids].reject(&:blank?) rescue nil
    @deallocate = [true, 'true'].include?(attributes[:deallocate])
    @allocating = attributes[:allocating]
    @claims = Claim::BaseClaim.find(@claim_ids) rescue nil
    @successful_claims = []
  end

  def save
    return false unless valid?
    result = true

    if allocating?
      allocate_all_claims_or_none!(@claims) if claims_in_correct_state_for?(:allocation)
    elsif deallocating?
      deallocate_claims(@claims) if claims_in_correct_state_for?(:deallocation)
    elsif reallocating?
      reallocate_claims(@claims) if claims_in_correct_state_for?(:reallocation)
    else
      raise "Should never get here!"
    end
    errors.empty?
  end
  
  def claims_in_correct_state_for?(new_state)
    @claims.each do |claim|
      errors[:base] << "Claim #{claim.id} cannot be transitioned to #{new_state} from #{claim.state}" unless claim.state.in?(VALID_STATES_FOR_TRANSITION[new_state])
    end
    errors[:base].empty?
  end

  def reallocate_claims(claims)
    claims.each { |claim| allocate_claim!(claim) }
  end

  def case_worker
    CaseWorker.find(@case_worker_id) rescue nil #deallocation will have a nil case worker id
  end

  def allocating?
    @allocating
  end

  private

  def allocate_all_claims_or_none!(claims)
    ActiveRecord::Base.transaction do
      claims.each do |claim|
        allocate_or_error_claim! claim
      end

      if errors.any?
        rollback_all_allocations!
      end
    end
  end

  def allocate_or_error_claim!(claim)
    if claim.case_workers.exists?
      errors.add(:base,"Claim #{claim.case_number} has already been allocated to #{claim.case_workers.first.name}")
    else
      allocate_claim! claim
    end
  end

  def rollback_all_allocations!
    errors[:base].unshift("NO claims allocated because: ")
    @successful_claims = []
    raise ActiveRecord::Rollback
  end

  def deallocating?
    @deallocate
  end

  def reallocating?
    !deallocating? && !allocating?
  end

  def deallocate_claims(claims)
    claims.each { |claim| deallocate_claim!(claim)}
  end

  def deallocate_claim!(claim)
    claim.case_workers.destroy_all
    claim.deallocate!
    successful_claims << claim
  end

  def allocate_claim!(claim)
    #NOTE: associating a case worker implicitly changes the state of the claim and saves via the state machine allocate! event method
    claim.case_workers.destroy_all
    claim.case_workers << case_worker
    successful_claims << claim
  end

end
