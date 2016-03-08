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
    if current_user.provider.has_roles?('lgfs') && (current_user.litigator? || current_user.admin?)
      @context = current_user.provider.claims_created
    elsif current_user.provider.has_roles?('agfs') && (current_user.advocate? || current_user.admin?)
      if current_user.admin?
        @context = current_user.provider.claims
      else
        @context = current_user.claims
      end
    elsif current_user.provider.has_roles?('agfs','lgfs') && current_user.has_roles?('advocate','admin')
      @context = current_user.provider.claims
    elsif current_user.provider.has_roles?('agfs','lgfs') && current_user.has_roles?('litigator','admin')
      @context = current_user.provider.claims_created
    elsif current_user.provider.has_roles?('agfs','lgfs') && ( current_user.has_roles?('admin') || current_user.has_roles?('advocate','litigator','admin') )
      @context = current_user.provider.claims_created.merge!(current_user.provider.claims)
    else
      raise "WARNING: agfs/lgfs firm logic incomplete"
    end
  end

  # TODO: old code to be removed
  # def set_context
  #   if current_user.persona.admin? && current_user.persona.provider
  #     @context = current_user.persona.provider
  #   else
  #     @context = current_user
  #   end
  # end

  def set_financial_summary
    @financial_summary = Claims::FinancialSummary.new(@context)
  end
end
