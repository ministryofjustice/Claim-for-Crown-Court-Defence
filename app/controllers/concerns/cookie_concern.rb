module CookieConcern
  extend ActiveSupport::Concern

  private

  def set_default_cookie_usage
    return set_cookie('usage_opt_in') if usage_cookies_not_set?

    if user_set_cookie_preference?
      set_cookie('usage_opt_in', value: params[:usage_opt_in])
      set_cookie('cookies_preference', value: true)
    end

    show_hide_cookie_banners
    set_datatracking_usage
  end

  def set_cookie(type, value: false)
    cookies[type] = {
      value: value,
      domain: request.host,
      expires: Time.zone.now + 1.year,
      secure: true
    }
  end

  def usage_cookies_not_set?
    cookies[:usage_opt_in].nil?
  end

  def user_set_cookie_preference?
    params[:usage_opt_in].present?
  end

  def cookies_preferences_set?
    cookies[:cookies_preference]
  end

  def show_hide_cookie_banners
    @cookies_preferences_set = cookies_preferences_set?
    @show_confirm_banner = params[:show_confirmation].presence || false
  end

  def set_datatracking_usage
    GoogleAnalytics::DataTracking.usage = cookies[:usage_opt_in]
  end
end
