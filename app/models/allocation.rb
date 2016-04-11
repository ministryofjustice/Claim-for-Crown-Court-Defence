class Allocation
  include ActiveModel::Model
  include ActiveModel::Validations

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

    # could be allocating, deallocating or reallocating
    if allocating?
      allocate_all_claims_or_none! @claims
    else
      @claims.each do |claim|
        if deallocating?
          deallocate_claim! claim
        else #reallocating
          allocate_claim! claim
        end
      end
    end

    true
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
