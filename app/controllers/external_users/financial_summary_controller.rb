class ExternalUsers::FinancialSummaryController < ExternalUsers::ApplicationController
  respond_to :html

  before_action :set_claims_context
  before_action :set_financial_summary, only: [:outstanding, :authorised]

  def outstanding
    @claims = @financial_summary.outstanding_claims
    @total_value = @financial_summary.total_outstanding_claim_value
  end

  def authorised
    @claims = @financial_summary.authorised_claims
    @total_value = @financial_summary.total_authorised_claim_value
  end

private

  def set_claims_context
    context = Claims::ContextMapper.new(current_user.persona)
    @claims_context = context.available_claims
  end

  def set_financial_summary
    @financial_summary = Claims::FinancialSummary.new(@claims_context)
  end
end
