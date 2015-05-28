class Advocates::ClaimsController < Advocates::ApplicationController
  respond_to :html
  before_action :set_claim, only: [:show, :edit, :summary, :update, :destroy]
  before_action :set_context, only: [:index, :outstanding, :authorised ]
  before_action :set_financial_summary, only: [:index, :outstanding, :authorised]

  def landing; end

  def index
    claims = @context.claims.order(created_at: :desc)
    claims = claims.find_by_advocate_name(params[:search]) if params[:search].present?

    @submitted_claims = claims.submitted
    @rejected_claims = claims.rejected
    @allocated_claims = claims.allocated
    @part_paid_claims = claims.part_paid
    @completed_claims = claims.completed
    @draft_claims = claims.draft
  end

  def outstanding
    @claims = @financial_summary.outstanding_claims
    @total_value = @financial_summary.total_outstanding_claim_value
  end

  def authorised
    @claims = @financial_summary.authorised_claims
    @total_value = @financial_summary.total_authorised_claim_value
  end

  def show
    @doc_types = DocumentType.all
    @messages = @claim.messages.most_recent_first
    @message = @claim.messages.build
  end

  def new
    @claim = Claim.new
    build_nested_resources
  end

  def edit
    redirect_to advocates_claims_url, notice: 'Can only edit "draft" or "submitted" claims' unless @claim.editable?
  end

  def summary
    session[:summary] = true
  end

  def confirmation; end

  def create
    @claim = Claim.new(claim_params.merge(creator_id: current_user.persona.id, advocate_id: current_user.persona.id))

    if @claim.save
      respond_with @claim, { location: summary_advocates_claim_path(@claim), notice: 'Claim successfully created' }
    else
      build_nested_resources
      render action: :new
    end
  end

  def update
    @claim.submit! if session.delete(:summary) && @claim.draft?

    @claim.update(claim_params)
    respond_with @claim, { location: update_redirect_location, notice: 'Claim successfully updated' }
  end

  def destroy
    if @claim.draft?
      @claim.destroy
      respond_with @claim, { location: advocates_claims_url, notice: 'Claim deleted' }
    else
      redirect_to advocates_claims_url, alert: 'Cannot destroy non-draft claim'
    end
  end

  private

  def set_context
    if current_user.persona.admin? && current_user.persona.chamber
      @context = current_user.persona.chamber
    else
      @context = current_user
    end
  end

  def set_claim
    @claim = Claim.find(params[:id])
  end

  def set_financial_summary
    @financial_summary = Claims::FinancialSummary.new(@context)
  end

  def claim_params
    params.require(:claim).permit(
     :advocate_id,
     :court_id,
     :scheme_id,
     :case_number,
     :case_type,
     :offence_id,
     :first_day_of_trial,
     :estimated_trial_length,
     :actual_trial_length,
     :advocate_category,
     :additional_information,
     :prosecuting_authority,
     :indictment_number,
     :apply_vat,
     defendants_attributes: [:id, :claim_id, :first_name, :middle_name, :last_name, :date_of_birth, :representation_order_date, :order_for_judicial_apportionment, :maat_reference, :_destroy],
     fees_attributes: [:id, :claim_id, :fee_type_id, :fee_id, :quantity, :rate, :amount, :_destroy],
     expenses_attributes: [:id, :claim_id, :expense_type_id, :location, :quantity, :rate, :hours, :amount, :_destroy],
     documents_attributes: [:id, :claim_id, :document_type_id, :document, :description]
    )
  end

  def build_nested_resources
    @claim.defendants.build if @claim.defendants.none?
    @claim.fees.build if @claim.fees.none?
    @claim.expenses.build if @claim.expenses.none?
    @claim.documents.build if @claim.documents.none?
  end

  def update_redirect_location
    if params[:summary]
      confirmation_advocates_claim_path(@claim)
    else
      summary_advocates_claim_path(@claim)
    end
  end
end
