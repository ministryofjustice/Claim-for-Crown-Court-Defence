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
    respond_to do |format|
      format.json { render json: offences, each_serializer: OffenceSerializer }
    end
  end

  private

  def offences
    return FeeReform::SearchOffences.call(permitted_params) if permitted_params[:fee_scheme].present?

    Offence.in_scheme_nine.where(offence_filter)
  end

  def permitted_params
    params.permit(:fee_scheme, :description, :search_offence, :category_id, :band_id)
  end

  def offence_filter
    {}.tap do |filters|
      filters.merge!(description: permitted_params[:description]) if permitted_params[:description].present?
    end
  end
end
