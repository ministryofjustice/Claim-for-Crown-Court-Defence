module SuperAdmins
  class StatsController < ApplicationController
    skip_load_and_authorize_resource only: :show
    def show
      @test = 'Test variable'
    end
  end
end
