class ExternalUsers::Advocates::InterimClaimsController < ExternalUsers::ClaimsController
  skip_load_and_authorize_resource

  resource_klass Claim::AdvocateInterimClaim
end
