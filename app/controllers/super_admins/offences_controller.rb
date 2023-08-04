module SuperAdmins
  class OffencesController < ApplicationController
    authorize_resource class: Offence

    def index
      @offences = OffencesSummaryService.call
    end
  end
end
