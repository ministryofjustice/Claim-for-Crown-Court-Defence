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
    @offences = Offence.includes(:offence_class)
    @offences = @offences.where(description: params[:description]) if params[:description].present?
  end
end
