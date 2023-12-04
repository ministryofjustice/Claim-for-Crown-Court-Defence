module SuperAdmins
  class SuperAdminsController < ApplicationController
    authorize_resource class: false

    def show; end

    private

    def filtered_params
      []
    end
  end
end
