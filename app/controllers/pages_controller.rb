class PagesController < ApplicationController

  skip_load_and_authorize_resource

  def tandcs; end

  def api_landing; end

  def api_release_notes; end

  def servicedown; end
end
