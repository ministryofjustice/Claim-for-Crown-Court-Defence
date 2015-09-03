class Advocates::ClaimsController < Advocates::ApplicationController
  # This performs magic
  include DateParamProcessor
  include DocTypes

  respond_to :html
  before_action :set_claim, only: [:show, :edit, :update, :destroy]
  before_action :set_doctypes, only: [:show]
  before_action :set_context, only: [:index, :outstanding, :authorised ]
  before_action :set_financial_summary, only: [:index, :outstanding, :authorised]
  before_action :set_search_options, only: [:index]
  before_action :load_advocates_in_chamber, only: [:new, :edit, :create, :update]

  def index
    @claims = @context.claims.order(created_at: :desc)
    search if params[:search].present?
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
    @messages = @claim.messages.most_recent_first
    @message = @claim.messages.build
    @enable_assessment_input = false
    @enable_status_change = false
  end

  def new
    @claim = Claim.new
    @claim.instantiate_basic_fees
    @advocates_in_chamber = current_user.persona.advocates_in_chamber if current_user.persona.admin?
    load_offences_and_case_types

    build_nested_resources
  end

  def edit
    build_nested_resources
    load_offences_and_case_types
    @disable_assessment_input = true

    redirect_to advocates_claims_url, notice: 'Can only edit "draft" or "submitted" claims' unless @claim.editable?
  end

  def confirmation; end

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
      submit_if_required_and_redirect
    else
      submit_claim_to_laa
    end
  end

  def destroy
    @claim.archive_pending_delete!
    respond_with @claim, { location: advocates_claims_url, notice: 'Claim deleted' }
  end

  private

  def load_offences_and_case_types
    @offence_descriptions = Offence.unique_name.order(description: :asc)
    if @claim.offence
      @offences = Offence.includes(:offence_class).where(description: @claim.offence.description)
    else
      @offences = Offence.includes(:offence_class)
    end
    @case_types = CaseType.all
  end

  def submit_if_required_and_redirect
    if submitting_to_laa?
      @claim.force_validation = true
      if @claim.valid?
        redirect_to new_advocates_claim_certification_path(@claim)
      else
        render_edit_with_resources
      end
    else
      redirect_to advocates_claims_path, notice: 'Draft claim saved'
    end
  end

  def search
    params[:search_field] ||= 'Defendant'
    @claims = @claims.search(*search_option_mappings[params[:search_field]], params[:search])
  end

  def search_option_mappings
    option_mappings = {
      'All'       => [:defendant_name],
      'Advocate'  => [:advocate_name],
      'Defendant' => [:defendant_name]
    }

    option_mappings['All'] << :advocate_name if current_user.persona.admin?
    option_mappings
  end

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
     :state_for_form,
     :source,
     :advocate_id,
     :court_id,
     :case_number,
     :case_type_id,
     :trial_fixed_notice_at_dd,
     :trial_fixed_notice_at_mm,
     :trial_fixed_notice_at_yyyy,
     :trial_fixed_at_dd,
     :trial_fixed_at_mm,
     :trial_fixed_at_yyyy,
     :trial_cracked_at_dd,
     :trial_cracked_at_mm,
     :trial_cracked_at_yyyy,
     :trial_cracked_at_third,
     :offence_id,
     :first_day_of_trial_dd,
     :first_day_of_trial_mm,
     :first_day_of_trial_yyyy,
     :estimated_trial_length,
     :actual_trial_length,
     :trial_concluded_at_dd,
     :trial_concluded_at_mm,
     :trial_concluded_at_yyyy,
     :advocate_category,
     :additional_information,
     :indictment_number,
     :apply_vat,
     :evidence_checklist_ids => [],
     defendants_attributes: [
       :id,
       :claim_id,
       :first_name,
       :middle_name,
       :last_name,
       :date_of_birth_dd,
       :date_of_birth_mm,
       :date_of_birth_yyyy,
       :order_for_judicial_apportionment,
       :_destroy,
       representation_orders_attributes: [
         :id,
         :document,
         :maat_reference,
         :representation_order_date_dd,
         :representation_order_date_mm,
         :representation_order_date_yyyy,
         :granting_body
        ]
     ],
     basic_fees_attributes: [
       :id,
       :claim_id,
       :fee_type_id,
       :fee_id,
       :quantity,
       :amount,
       :_destroy,
       dates_attended_attributes: [
          :id,
          :fee_id,
          :date_dd,
          :date_mm,
          :date_yyyy,
          :date_to_dd,
          :date_to_mm,
          :date_to_yyyy,
          :_destroy
        ]
     ],
      fixed_fees_attributes: [
       :id,
       :claim_id,
       :fee_type_id,
       :fee_id,
       :quantity,
       :amount,
       :_destroy,
       dates_attended_attributes: [
          :id,
          :fee_id,
          :date_dd,
          :date_mm,
          :date_yyyy,
          :date_to_dd,
          :date_to_mm,
          :date_to_yyyy,
          :_destroy
        ]
      ],
      misc_fees_attributes: [
       :id,
       :claim_id,
       :fee_type_id,
       :fee_id,
       :quantity,
       :amount,
       :_destroy,
       dates_attended_attributes: [
          :id,
          :fee_id,
          :date_dd,
          :date_mm,
          :date_yyyy,
          :date_to_dd,
          :date_to_mm,
          :date_to_yyyy,
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
       :_destroy,
       dates_attended_attributes: [
          :id,
          :expense_id,
          :date_dd,
          :date_mm,
          :date_yyyy,
          :date_to_dd,
          :date_to_mm,
          :date_to_yyyy,
          :_destroy
        ]
     ],
     documents_attributes: [
       :id,
       :document,
       :advocate_id,
       :claim_id,
       :_destroy
     ]
    )
  end

  def build_nested_resources
    [:defendants, :fixed_fees, :misc_fees, :expenses, :documents].each do |association|
      build_nested_resource(@claim, association)
    end

    @claim.defendants.each { |d| build_nested_resource(d, :representation_orders) }
  end

  def build_nested_resource(object, association)
    object.send(association).build if object.send(association).none?
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
    load_offences_and_case_types
    render action: :edit
  end

  def render_new_with_resources
    @claim.fees = @claim.instantiate_basic_fees(claim_params['basic_fees_attributes']) if @claim.new_record?
    build_nested_resources
    load_offences_and_case_types
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
    @claim.force_validation = true
    @claim.save
    if @claim.valid?
      redirect_to new_advocates_claim_certification_path(@claim)
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
