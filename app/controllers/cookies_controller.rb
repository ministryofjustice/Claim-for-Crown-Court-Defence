class CookiesController < ApplicationController
  skip_load_and_authorize_resource only: %i[new create cookie_details]

  def new
    @cookies = Cookies.new
    @cookies.analytics = false

    render
  end

  def create
    @cookies = Cookies.new(cookies_params[:cookies])

    if @cookies.valid?
      flash[:notice] = 'Your cookie settings were saved'

      set_cookies_policy(@cookies.analytics)
    end

    render :new
  end

  private

  def cookies_params
    params.permit(cookies: :analytics)
  end

  def set_cookies_policy(usage)
    cookies[:cookies_policy] = {
      value: {
        "essential":true,
        "usage":usage
      },
      # domain: Request.Url.Host,
      expires: Time.now + 1.years,
      secure: true
    }
  end
end
