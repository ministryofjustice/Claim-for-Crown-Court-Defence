class ClaimsController < ApplicationController
  respond_to :html
  before_action :set_claim, only: [:show, :edit, :update, :destroy]

  def index
    @claims = Claim.all
  end

  def show; end

  def new
    @claim = Claim.new

    3.times do
      @claim.defendants.build
    end

    3.times do
      @claim.claim_fees.build
    end

    3.times do
      @claim.expenses.build
    end
  end

  def edit; end

  def create
    @claim = Claim.new(claim_params)
    if @claim.save
      respond_with @claim, { location: root_url, notice: 'Claim successfully created' }
    else
      3.times do
        @claim.defendants.build
      end

      3.times do
        @claim.claim_fees.build
      end

      3.times do
        @claim.expenses.build
      end

      render action: :new
    end
  end

  def update
    if @claim.update(claim_params)
      respond_with @claim, { location: root_url, notice: 'Claim successfully updated' }
    else
      render action: :edit
    end
  end

  def destroy
    @claim.destroy
    respond_with @claim, { location: root_url, notice: 'Claim deleted' }
  end

  private

  def set_claim
    @claim = Claim.find(params[:id])
  end

  def claim_params
    params.require(:claim).permit(
     :advocate,
     :advocate_id,
     defendants_attributes: [:id, :claim_id, :first_name, :middle_name, :last_name, :date_of_birth, :representation_order_date, :order_for_judicial_apportionment, :maat_ref_nos, :_destroy],
     claim_fees_attributes: [:id, :fee_id, :quantity, :rate, :amount, :_destroy],
     expenses_attributes: [:id, :claim_id, :expense_type_id, :quantity, :rate, :hours, :amount, :_destroy]
    )
  end
end
