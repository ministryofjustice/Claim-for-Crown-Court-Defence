class PasswordsController < Devise::PasswordsController
  skip_load_and_authorize_resource
  before_action { DualLogin.new(session).clear }
end
