class SessionsController < Devise::SessionsController
  skip_load_and_authorize_resource only: [:new, :create, :destroy]
end
