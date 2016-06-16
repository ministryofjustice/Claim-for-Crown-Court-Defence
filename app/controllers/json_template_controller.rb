class JsonTemplateController < ApplicationController

  skip_load_and_authorize_resource only: [:index]

  def index
    @schema = JSON.parse(JsonSchema.claim_schema)
  end
end
