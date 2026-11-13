class DualLogin
  def self.public_rollout?
    FeatureFlag.active?(:dual_login)
  end

  def self.eligible?(user)
    public_rollout? || user&.login_route&.dual_login_tester? == true
  end

  def initialize(session)
    @session = session
  end

  def identify(email)
    clear
    user = User.find_by(email: email.strip.downcase)
    return unless self.class.eligible?(user)

    @session[:dual_login] = {
      'email' => email.strip.downcase,
      'user_id' => user&.id,
      'login_method' => method_for(user)
    }
  end

  def allowed?(method)
    return false if email.blank? || login_method != method

    user = User.find_by(email: email)
    user&.id == state['user_id'] && method_for(user) == method && self.class.eligible?(user)
  end

  def email
    state['email']
  end

  def login_method
    state['login_method']
  end

  def clear
    @session.delete(:dual_login)
    @session.delete(:legacy_sign_in_email)
    @session.delete(:entra_sign_in_email)
  end

  private

  def state
    @session[:dual_login] || {}
  end

  def method_for(user)
    user&.login_route&.login_method || LoginRoute::DEFAULT_LOGIN_METHOD
  end
end
