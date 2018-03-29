# == Schema Information
#
# Table name: offences
#
#  id               :integer          not null, primary key
#  description      :string
#  offence_class_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#

class OffencesController < ApplicationController
  skip_load_and_authorize_resource only: [:index]

  def index
    if params[:fee_scheme] && params[:fee_scheme] == 'fee_reform'
      @offences = FeeReform::SearchOffences.call(params)

      respond_to do |format|
        format.json do
          render json: @offences, each_serializer: FeeReform::OffenceSerializer
        end
      end
    else
      @offences = Offence.in_scheme_nine.where(offence_filter)
    end
  end

  private

  def offence_filter
    {}.tap do |filters|
      filters.merge!(description: params[:description]) if params[:description].present?
    end
  end
end
