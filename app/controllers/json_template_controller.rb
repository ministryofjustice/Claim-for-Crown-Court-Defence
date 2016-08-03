class JsonTemplateController < ApplicationController

  skip_load_and_authorize_resource only: [:index]

  def index
    @schema = JSON.parse(ClaimJsonSchemaValidator.full_schema)
  end
end
