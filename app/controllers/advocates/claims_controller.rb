class Advocates::ClaimsController < Advocates::ApplicationController
  respond_to :html
  before_action :set_claim, only: [:show, :edit, :summary, :update, :destroy]

  def index
    @claims = Claim.all
  end

  def show; end

  def new
    @claim = Claim.new

    @claim.defendants.build
    @claim.claim_fees.build
    @claim.expenses.build
  end

  def edit; end

  def summary; end

  def confirmation; end

  def create
    @claim = Claim.new(claim_params.merge(advocate_id: current_user.id))

    if @claim.save
      respond_with @claim, { location: summary_advocates_claim_path(@claim), notice: 'Claim successfully created' }
    else
      @claim.defendants.build
      @claim.claim_fees.build
      @claim.expenses.build

      render action: :new
    end
  end

  def update
    if @claim.update(claim_params)
      respond_with @claim, { location: confirmation_advocates_claim_path(@claim), notice: 'Claim successfully updated' }
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
     :additional_information,
     :vat_required,
     defendants_attributes: [:id, :claim_id, :first_name, :middle_name, :last_name, :date_of_birth, :representation_order_date, :order_for_judicial_apportionment, :maat_ref_nos, :_destroy],
     claim_fees_attributes: [:id, :claim_id, :fee_id, :quantity, :rate, :amount, :_destroy],
     expenses_attributes: [:id, :claim_id, :expense_type_id, :quantity, :rate, :hours, :amount, :_destroy]
    )
  end
end
