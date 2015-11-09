class CaseTypesController < ApplicationController
  skip_load_and_authorize_resource only: [:show]

  def show
    @case_type = CaseType.find(params[:id])
  end
end
