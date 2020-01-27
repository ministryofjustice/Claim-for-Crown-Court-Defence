class PagesController < ApplicationController
  skip_load_and_authorize_resource
  before_action :suppress_hotline_link

  def tandcs; end

  def contact_us; end

  def api_landing; end

  def api_release_notes; end

  def servicedown
    respond_to do |format|
      format.html do
        render :servicedown, layout: 'basic'
      end
      format.json do
        render  json:
                [{ error: 'Service temporarily unavailable' }],
                status: 503
      end
      format.js do
        render  json:
                [{ error: 'Service temporarily unavailable' }],
                status: 503
      end
      format.all do
        render  plain: 'error: Service temporarily unavailable',
                status: 503
      end
    end
  end

  def timed_retention; end
end
