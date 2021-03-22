class CookiesController < ApplicationController
  skip_load_and_authorize_resource only: %i[new create cookie_details]

  def new
    usage_cookie = cookies[:usage_opt_in]
    @cookies = Cookies.new(analytics: usage_cookie)

    render
  end

  def create
    @cookies = Cookies.new(cookies_params[:cookies])

    if @cookies.valid?
      flash[:success] = t('cookies.new.cookie_notification')

      set_usage_policy(@cookies.analytics)
      set_cookie_preference
      @has_cookies_preferences_set = has_cookies_preferences_set?
    end

    redirect_to cookies_path
  end

  private

  def cookies_params
    params.permit(cookies: :analytics)
  end
end
