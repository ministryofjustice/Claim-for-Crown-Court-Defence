class Allocation
  include ActiveModel::Model
  include ActiveModel::Validations

  class << self
    def i18n_scope
      :activerecord
    end
  end

  attr_accessor :case_worker_id, :claim_ids, :deallocate

  validates :case_worker_id, presence: true, unless: :deallocating?
  validates :claim_ids, presence: true

  def initialize(attributes = {})
    @case_worker_id = attributes[:case_worker_id]
    @claim_ids = attributes[:claim_ids].reject(&:blank?) rescue nil
    @deallocate = [true, 'true'].include?(attributes[:deallocate])
  end

  def save
    return false unless valid?
    claims.each do |claim|
      claim.case_workers.destroy_all
      claim.case_workers << case_worker unless deallocating?
      claim.update_column(:state, claim.last_state_transition.from) if deallocating?
    end
    true
  end

  private

  def deallocating?
    @deallocate
  end

  def claims
    Claim::BaseClaim.find(@claim_ids)
  end

  def case_worker
    CaseWorker.find(@case_worker_id)
  end
end
