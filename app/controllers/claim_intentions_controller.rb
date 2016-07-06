# == Schema Information
#
# Table name: claim_intentions
#
#  id         :integer          not null, primary key
#  form_id    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#

class ClaimIntentionsController < ApplicationController
  def create
    @claim_intention = ClaimIntention.new(claim_intention_params)

    if @claim_intention.save
      head :created
    else
      head :bad_request
    end
  end

  private

  def claim_intention_params
    params.require(:claim_intention).permit(
      :form_id
    ).merge(user_id: current_user.id)
  end
end
