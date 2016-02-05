require 'CGI'

module ApplicationHelper

  #
  # Can be called in views in order to instantiate a presenter for a partilcular model
  # following the <Model>Presenter naming convention or, optionally, a named presenter
  # class:
  # e.g. - present(@advocate)
  # e.g. - present(@advocate, AdminAdvocatePresenter)
  #
  def present(model, presenter_class=nil)
    presenter_class ||= "#{model.class}Presenter".constantize
    presenter = presenter_class.new(model, self)
    yield(presenter) if block_given?
    presenter
  end

  # TODO: this will not work on those routes that are also rooted to for the namespace or which have js that interferes
  def cp(path)
    tab = extract_uri_param(path, 'tab')
    if tab.present?
      "current" if request.path == strip_params(path) && extract_uri_param(request.fullpath,'tab') == tab
    else
      "current" if request.path == strip_params(path)
    end
  end

  def number_with_precision_or_default(number, options = {})
    default = options.delete(:default) || ''
    if options.has_key?(:precision)
      number == 0 ? default : number_with_precision(number, options)
    else
      number == 0 ? default : number.to_s
    end
  end

  def casual_date(date)
    if Date.parse(date) == Date.today
      "Today"
    elsif Date.parse(date) == Date.yesterday
      "Yesterday"
    else
      date
    end
  end

  def ga_outlet
    if flash[:ga]
      flashes = []
      flash[:ga].map do |item|
        item.each do |type, data|
          flashes << "ga('send', '#{type}', '#{data.join("','")}');".html_safe
        end
      end
      flashes.join("\n")
    end
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    title = column == sort_column ? ("#{title} " + (sort_direction == 'asc' ? "\u25B2" : "\u25BC")) : title
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == 'asc' ? 'desc' : 'asc'
    link_to title, params.except(:page).merge({ sort: column, direction: direction }), { class: css_class }
  end

  def extract_uri_param(path,param)
    uri = URI.parse(path)
    CGI.parse(uri.query)[param][0]
  rescue
    nil
  end

  def strip_params(path)
    path.split('?')[0]
  end
end
