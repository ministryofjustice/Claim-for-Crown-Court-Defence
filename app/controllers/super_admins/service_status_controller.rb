module SuperAdmins
  class ServiceStatusController < ApplicationController
    skip_load_and_authorize_resource

    def index; end
  end
end
