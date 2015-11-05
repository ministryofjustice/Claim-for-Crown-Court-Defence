

class PagesController < ApplicationController

  skip_load_and_authorize_resource

  def tandcs
    render
  end

  def api_landing
    render
  end

end
