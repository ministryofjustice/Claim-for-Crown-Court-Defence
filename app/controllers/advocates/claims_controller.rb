class Advocates::ClaimsController < Advocates::ApplicationController
  respond_to :html
  before_action :set_claim, only: [:show, :edit, :summary, :update, :destroy]


  def index
    # parent can be a chamber or an advocate
    parent = current_user.persona.admin? ? current_user.persona.chamber : current_user

    claims = parent.claims.order(created_at: :desc)
    claims = claims.find_by_advocate_name(params[:search]) if params[:search].present?

    @submitted_claims = claims.submitted
    @allocated_claims = claims.allocated
    @completed_claims = claims.completed
    @draft_claims = claims.draft
    @claims_summary  = Claims::Summary.new(parent)
  end

  def show; end

  def new
    @claim = Claim.new
    build_nested_resources
  end

  def edit; end

  def summary
    session[:summary] = true
  end

  def confirmation; end

  def create
    @claim = Claim.new(claim_params.merge(advocate_id: current_user.persona.id))

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
    @claim.destroy
    respond_with @claim, { location: advocates_root_url, notice: 'Claim deleted' }
  end

  private

  def set_claim
    @claim = Claim.find(params[:id])
  end

  def claim_params
    params.require(:claim).permit(
     :advocate_id,
     :court_id,
     :scheme_id,
     :case_number,
     :case_type,
     :offence_id,
     :advocate_category,
     :additional_information,
     :prosecuting_authority,
     :indictment_number,
     :apply_vat,
     defendants_attributes: [:id, :claim_id, :first_name, :middle_name, :last_name, :date_of_birth, :representation_order_date, :order_for_judicial_apportionment, :maat_reference, :_destroy],
     fees_attributes: [:id, :claim_id, :fee_id, :quantity, :rate, :amount, :_destroy],
     expenses_attributes: [:id, :claim_id, :expense_type_id, :quantity, :rate, :hours, :amount, :_destroy],
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
