class ClaimsController < ApplicationController
  respond_to :html
  before_action :set_claim, only: [:show, :edit, :update, :destroy]

  def index
    @claims = Claim.all
  end

  def show; end

  def new
    @claim = Claim.new
  end

  def edit; end

  def create
    @claim = Claim.new(claim_params)
    if @claim.save
      respond_with @claim, { location: root_url, notice: 'Claim successfully created' }
    else
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
     :advocate_id
    )
  end
end
