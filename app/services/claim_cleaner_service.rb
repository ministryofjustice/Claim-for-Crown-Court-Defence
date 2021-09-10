class ClaimCleanerService
  attr_accessor :claim

  delegate_missing_to :claim

  def initialize(claim)
    @claim = claim
  end

  def call
    destroy_invalid_fees
    destroy_invalid_disbursements
    clear_inapplicable_fields
  end

  private

  def destroy_invalid_fees; end
  def destroy_invalid_disbursements; end
  def clear_inapplicable_fields; end
end
