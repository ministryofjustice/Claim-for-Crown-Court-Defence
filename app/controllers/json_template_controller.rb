class JsonTemplateController < ApplicationController
  skip_load_and_authorize_resource only: [:index]

  def index
    @schema = ClaimJsonSchemaValidator.full_schema
  end
end
