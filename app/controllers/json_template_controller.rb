class JsonTemplateController < ApplicationController
  skip_load_and_authorize_resource only: [:index, :show]

  before_action :set_schema, only: :show

  def index
    @schema = ClaimJsonSchemaValidator.full_schema
  end

  def show
    render json: @schema
  end

  private

  def set_schema
    @schema = ClaimJsonSchemaValidator.send(schema_params[:schema].to_sym)
  end

  def schema_params
    params.permit(:schema)
  end
end
