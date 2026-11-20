class DualLoginGate
  ENTRA_PATH = %r{\A/users/auth/entra_(?:id|mock)(?:/callback)?\z}i

  def initialize(app)
    @app = app
  end

  def call(env)
    return @app.call(env) unless ENTRA_PATH.match?(env['PATH_INFO'])

    request = ActionDispatch::Request.new(env)
    flow = DualLogin.new(request.session)
    return @app.call(env) if flow.allowed?(LoginRoute::ENTRA)

    flow.clear
    reject(request)
  end

  private

  def reject(request)
    request.flash[:alert] = I18n.t('session_routing.unavailable')
    request.commit_flash
    [302, { 'location' => Rails.application.routes.url_helpers.sign_in_path, 'content-type' => 'text/html' }, []]
  end
end
