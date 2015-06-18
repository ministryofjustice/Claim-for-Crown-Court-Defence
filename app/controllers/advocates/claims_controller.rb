class Advocates::ClaimsController < Advocates::ApplicationController
  respond_to :html
  before_action :set_claim, only: [:show, :edit, :update, :destroy]
  before_action :set_context, only: [:index, :outstanding, :authorised ]
  before_action :set_financial_summary, only: [:index, :outstanding, :authorised]
  before_action :set_search_options, only: [:index]
  before_action :load_advocates_in_chamber, only: [:new, :edit, :create, :update]

  def landing; end

  def index
    add_breadcrumb 'Dashboard', advocates_root_path

    claims = @context.claims.order(created_at: :desc)

    params[:search_field] ||= 'Defendant'

    if params[:search].present?
      claims = case params[:search_field]
        when 'All'
          claims.search(:advocate_name, :defendant_name, params[:search])
        when 'Advocate'
          claims.search(:advocate_name, params[:search])
        when 'Defendant'
          claims.search(:defendant_name, params[:search])
      end
    end

    @claims = claims

    @draft_claims     = claims.advocate_dashboard_draft
    @rejected_claims  = claims.advocate_dashboard_rejected
    @submitted_claims = claims.advocate_dashboard_submitted
    @part_paid_claims = claims.advocate_dashboard_part_paid
    @completed_claims = claims.advocate_dashboard_completed
  end

  def outstanding
    add_breadcrumb 'Dashboard', advocates_root_path
    add_breadcrumb 'Outstanding', outstanding_advocates_claims_path

    @claims = @financial_summary.outstanding_claims
    @total_value = @financial_summary.total_outstanding_claim_value
  end

  def authorised
    add_breadcrumb 'Dashboard', advocates_root_path
    add_breadcrumb 'Authorised', authorised_advocates_claims_path

    @claims = @financial_summary.authorised_claims
    @total_value = @financial_summary.total_authorised_claim_value
  end

  def show
    add_breadcrumb 'Dashboard', advocates_root_path
    add_breadcrumb "Claim: #{@claim.case_number}", advocates_claim_path(@claim)

    @doc_types = DocumentType.all
    @messages = @claim.messages.most_recent_first
    @message = @claim.messages.build
  end

  def new
    add_breadcrumb 'Dashboard', advocates_root_path
    add_breadcrumb "New claim", new_advocates_claim_path

    @claim = Claim.new
    @claim.instantiate_basic_fees
    @advocates_in_chamber = current_user.persona.advocates_in_chamber if current_user.persona.admin?
    build_nested_resources
  end

  def edit
    add_breadcrumb 'Dashboard', advocates_root_path
    add_breadcrumb "Claim: #{@claim.case_number}", advocates_claim_path(@claim)
    add_breadcrumb "Edit", edit_advocates_claim_path(@claim)

    redirect_to advocates_claims_url, notice: 'Can only edit "draft" or "submitted" claims' unless @claim.editable?
  end

  def confirmation
    add_breadcrumb 'Dashboard', advocates_root_path
    add_breadcrumb "Claim: #{@claim.case_number}", advocates_claim_path(@claim)
    add_breadcrumb "Confirmation", edit_advocates_claim_path(@claim)
  end

  def create
    @claim = Claim.new(params_with_advocate_and_creator)
    @claim.documents.each { |d| d.advocate_id = @claim.advocate_id }

    if submitting_to_laa?
      create_and_submit
    else
      create_draft
    end
  end

  def update
    if @claim.update(claim_params)
      if submitting_to_laa?
        submit_claim_to_laa
      else
        redirect_to advocates_claims_path, notice: 'Draft claim saved'
      end
    else
      render_edit_with_resources
    end
  end

  def destroy
    @claim.archive_pending_delete!
    respond_with @claim, { location: advocates_claims_url, notice: 'Claim deleted' }
  end

  private

  def load_advocates_in_chamber
    @advocates_in_chamber = current_user.persona.advocates_in_chamber if current_user.persona.admin?
  end

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
     defendants_attributes: [
       :id,
       :claim_id,
       :first_name,
       :middle_name,
       :last_name,
       :date_of_birth,
       :representation_order_date,
       :order_for_judicial_apportionment,
       :maat_reference,
       :_destroy,
       representation_orders_attributes: [ :document ]
     ],
     basic_fees_attributes: [
       :id,
       :claim_id,
       :fee_type_id,
       :fee_id,
       :quantity,
       :rate,
       :_destroy,
       dates_attended_attributes: [
          :id,
          :fee_id,
          :date,
          :date_to,
          :_destroy
        ]
     ],
     non_basic_fees_attributes: [
       :id,
       :claim_id,
       :fee_type_id,
       :fee_id,
       :quantity,
       :rate,
       :_destroy,
       dates_attended_attributes: [
          :id,
          :fee_id,
          :date,
          :date_to,
          :_destroy
        ]
      ],
     expenses_attributes: [
       :id,
       :claim_id,
       :expense_type_id,
       :location,
       :quantity,
       :rate,
       :_destroy
     ],
     documents_attributes: [
       :id,
       :notes,
       :advocate_id,
       :claim_id,
       :document_type_id,
       :document,
       :description,
       :_destroy
     ],
     document_type_ids: []
    )
  end

  def build_nested_resources
    @claim.defendants.build if @claim.defendants.none?
    @claim.defendants.each { |d| d.representation_orders.build if d.representation_orders.none? }
    @claim.non_basic_fees.build if @claim.non_basic_fees.none?
    @claim.expenses.build if @claim.expenses.none?
    @claim.documents.build if @claim.documents.none?
  end

  def set_search_options
    if current_user.persona.admin?
      @search_options = ['All', 'Advocate', 'Defendant']
    else
      @search_options = ['All', 'Defendant']
    end
  end

  def saving_to_draft?
    params[:commit] == 'Save to drafts'
  end

  def submitting_to_laa?
    params[:commit] == 'Submit to LAA'
  end

  def render_edit_with_resources
    build_nested_resources
    render action: :edit
  end

  def render_new_with_resources
    @claim.fees = @claim.instantiate_basic_fees(claim_params['basic_fees_attributes'])
    build_nested_resources
    render action: :new
  end

  def params_with_advocate_and_creator
    form_params = claim_params
    form_params[:advocate_id] = current_user.persona.id unless current_user.persona.admin?
    form_params[:creator_id] = current_user.persona.id
    form_params
  end

  def create_draft
    if @claim.save
      redirect_to advocates_claims_path, notice: 'Draft claim saved'
    else
      render_new_with_resources
    end
  end

  def create_and_submit
    if @claim.submit && @claim.save
      redirect_to confirmation_advocates_claim_path(@claim), notice: 'Claim submitted to LAA'
    else
      render_new_with_resources
    end
  end

  def submit_claim_to_laa
    begin
      @claim.submit! unless @claim.submitted?
      redirect_to confirmation_advocates_claim_path(@claim), notice: 'Claim submitted to LAA'
    rescue
      render_edit_with_resources
    end
  end
end
