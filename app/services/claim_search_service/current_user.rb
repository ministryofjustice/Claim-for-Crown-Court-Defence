class ClaimSearchService
  class CurrentUser < Base
    def initialize(search, user:)
      super

      @user = user
    end

    def run
      @user.claims.where(id: @search.run)
    end

    def self.decorate(search, user: nil, current_user_claims: false, **_params)
      return search unless user && current_user_claims

      new(search, user: user)
    end
  end
end
