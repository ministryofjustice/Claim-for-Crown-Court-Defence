class UnlocksController < Devise::UnlocksController
  skip_load_and_authorize_resource
end
