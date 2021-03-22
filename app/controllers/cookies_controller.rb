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
      add_and_update_cookies
      @has_cookies_preferences_set = has_cookies_preferences_set?
      redirect_to cookies_path
    else
      render :new
    end
  end

  private

  def add_and_update_cookies
    set_cookie("usage_opt_in", @cookies.analytics)
    set_cookie("cookies_preference", true)
  end

  def cookies_params
    params.permit(cookies: :analytics)
  end
end
