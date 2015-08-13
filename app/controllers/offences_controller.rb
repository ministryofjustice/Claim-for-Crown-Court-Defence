class OffencesController < ApplicationController
  skip_load_and_authorize_resource only: [:index]

  def index
    @offences = Offence.includes(:offence_class)
    @offences = @offences.where(description: params[:description]) if params[:description].present?
  end
end
