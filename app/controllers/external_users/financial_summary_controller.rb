class ExternalUsers::FinancialSummaryController < ExternalUsers::ApplicationController
  respond_to :html

  before_action :set_context
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

  def set_context
    if current_user.persona.admin? && current_user.persona.provider
      @context = current_user.persona.provider
    else
      @context = current_user
    end
  end

  def set_financial_summary
    @financial_summary = Claims::FinancialSummary.new(@context)
  end
end
