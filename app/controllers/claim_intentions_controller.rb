class ClaimIntentionsController < ApplicationController
  def create
    @claim_intention = ClaimIntention.new(claim_intention_params)

    if @claim_intention.save
      render json: { claim_intention: @claim_intention.reload }, status: :created
    else
      render json: { error: @claim_intention.errors[:claim_intention].join(', ') }, status: 400
    end
  end

  private

  def claim_intention_params
    params.require(:claim_intention).permit(
      :form_id
    )
  end
end
