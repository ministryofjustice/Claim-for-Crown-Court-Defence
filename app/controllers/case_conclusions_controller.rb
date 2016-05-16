
# Used to conditionally show or hide
# case conclusion field based on forms
# current transfer details


class CaseConclusionsController < ApplicationController

  skip_load_and_authorize_resource only: [:index]

  def index
    @transfer_detail = Claim::TransferDetail.new( litigator_type: params[:litigator_type],
                                                   elected_case: elected_case?,
                                                   transfer_stage_id: params[:transfer_stage_id])
  end

private

  def elected_case?
    # default to true to hide in most cases
    elected_case = ['true','false'].include?(params[:elected_case]) ? params[:elected_case] : 'true'
    elected_case
  end
end
