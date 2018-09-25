class EstablishmentsController < ApplicationController
  skip_load_and_authorize_resource only: [:index]

  def index
    @establishments = Establishment.where(filters)
    respond_to do |format|
      format.json do
        render json: @establishments, each_serializer: EstablishmentSerializer
      end
    end
  end

  private

  def permitted_params
    params.permit(:category, :format)
  end

  def filters
    {}.tap do |hash|
      hash.merge!(category: permitted_params[:category]) if permitted_params[:category].present?
    end
  end
end
