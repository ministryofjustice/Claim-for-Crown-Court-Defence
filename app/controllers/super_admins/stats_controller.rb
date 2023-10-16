module SuperAdmins
  class StatsController < ApplicationController
    skip_load_and_authorize_resource only: :show
    def show
      @dummy_data_1 = {'AGFS 9': 2,
                       'AGFS 10': 10,
                       'AGFS 11': 12,
                       'AGFS 13': 8,
                       'AGFS 14': 15,
                       'AGFS 15': 22,
                       'LGFS 9': 8,
                       'LGFS 10': 33}
      @dummy_data_2 = {'AGFS 9': 34.56,
                       'AGFS 10': 1000.34,
                       'AGFS 11': 120.43,
                       'AGFS 13': 86.78,
                       'AGFS 14': 153.29,
                       'AGFS 15': 2030.45,
                       'LGFS 9': 135.65,
                       'LGFS 10': 2582.56}
      @dummy_data_3 = Claim::BaseClaim.group_by_day(:last_submitted_at).count
    end
  end
end
