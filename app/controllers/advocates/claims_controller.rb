class Advocates::ClaimsController < Advocates::ApplicationController
  respond_to :html
  before_action :set_claim, only: [:show, :edit, :summary, :update, :destroy]

  def index
    @claims = current_user.claims_created.order(created_at: :desc)
  end

  def show; end

  def new
    @claim = Claim.new
    build_nested_resources
  end

  def edit; end

  def summary; end

  def confirmation; end

  def create
    @claim = Claim.new(claim_params.merge(advocate_id: current_user.id))

    if @claim.save
      respond_with @claim, { location: summary_advocates_claim_path(@claim), notice: 'Claim successfully created' }
    else
      build_nested_resources
      render action: :new
    end
  end

  def update
    if @claim.update(claim_params) && @claim.submit!
      respond_with @claim, { location: update_redirect_location, notice: 'Claim successfully updated' }
    else
      render action: :edit
    end
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
     :case_number,
     :case_type,
     :offence_class,
     :additional_information,
     :vat_required,
     defendants_attributes: [:id, :claim_id, :first_name, :middle_name, :last_name, :date_of_birth, :representation_order_date, :order_for_judicial_apportionment, :maat_ref_nos, :_destroy],
     claim_fees_attributes: [:id, :claim_id, :fee_id, :quantity, :rate, :amount, :_destroy],
     expenses_attributes: [:id, :claim_id, :expense_type_id, :quantity, :rate, :hours, :amount, :_destroy]
    )
  end

  def build_nested_resources
    @claim.defendants.build if @claim.defendants.none?
    @claim.claim_fees.build if @claim.claim_fees.none?
    @claim.expenses.build if @claim.expenses.none?
  end

  def update_redirect_location
    if params[:summary]
      confirmation_advocates_claim_path(@claim)
    else
      summary_advocates_claim_path(@claim)
    end
  end
end
