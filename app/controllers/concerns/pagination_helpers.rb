module PaginationHelpers
  extend ActiveSupport::Concern

  DEFAULT_PAGE_SIZE ||= 10

  private

  def page_size
    limit = params[:limit].to_i
    limit > 0 ? limit : DEFAULT_PAGE_SIZE
  end

  def current_page
    params[:page]
  end
end
