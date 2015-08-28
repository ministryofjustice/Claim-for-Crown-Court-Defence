class PasswordsController < Devise::PasswordsController
  skip_load_and_authorize_resource
end
