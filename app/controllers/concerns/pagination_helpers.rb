module PaginationHelpers
  extend ActiveSupport::Concern

  private

  # Override this method in your class to change the default
  def default_page_size
    10
  end

  def page_size
    limit = params[:limit].to_i
    limit > 0 ? limit : default_page_size
  end

  def current_page
    params[:page]
  end
end
