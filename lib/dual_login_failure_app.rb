require 'devise/failure_app'

class DualLoginFailureApp < Devise::FailureApp
  protected

  def route(scope)
    scope == :user ? :sign_in_url : super
  end
end
