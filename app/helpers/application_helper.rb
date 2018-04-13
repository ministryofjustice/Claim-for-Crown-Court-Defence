module ApplicationHelper
  def current_user_is_caseworker?
    current_user.persona.is_a?(CaseWorker)
  end

  def current_user_is_external_user?
    current_user.persona.is_a?(ExternalUser)
  end

  #
  # Can be called in views in order to instantiate a presenter for a partilcular model
  # following the <Model>Presenter naming convention or, optionally, a named presenter
  # class.
  #
  # For instances:
  # e.g. - present(@advocate)
  # e.g. - present(@advocate, AdminAdvocatePresenter)
  #
  # For collections:
  # e.g. - present_collection(@claims)
  # e.g. - present_collection(@claims, ClaimPresenter)
  #
  def present(model, presenter_class = nil)
    presenter_class ||= presenter_for(model)
    presenter = presenter_class.new(model, self)
    yield(presenter) if block_given?
    presenter
  end

  def present_collection(model_collection, presenter_class = nil)
    presenter_collection = model_collection.each.map do |model_instance|
      present(model_instance, presenter_class)
    end
    yield(presenter_collection) if block_given?
    presenter_collection
  end

  def presenter_for(model)
    model.respond_to?(:presenter) ? model.presenter : "#{model.class}Presenter".constantize
  end

  # Returns a "current" css class if the path = current_page
  # TODO: this will not work on those routes that are also rooted to for the namespace or which have js that interferes
  def cp(path)
    tab = extract_uri_param(path, 'tab')
    if tab.present?
      'current' if request.path == strip_params(path) && request.GET[:tab] == tab
    else
      'current' if request.path == strip_params(path)
    end
  end

  def number_with_precision_or_default(number, options = {})
    default = options.delete(:default) || ''
    if options.key?(:precision)
      number.zero? ? default : number_with_precision(number, options)
    else
      number.zero? ? default : number.to_s
    end
  end

  def casual_date(date)
    if Date.parse(date) == Date.today
      'Today'
    elsif Date.parse(date) == Date.yesterday
      'Yesterday'
    else
      date
    end
  end

  def ga_outlet
    if flash[:ga].present?
      flash[:ga].join("\n")
    else
      "ga('send', 'pageview');"
    end
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    title = column == sort_column ? ("#{title} " + column_sort_icon) : title

    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == 'asc' ? 'desc' : 'asc'

    # TODO: whitelist the permitted params!!!
    # Right now not sure what they are so using permit! is known to be a BAD workaround
    # non-sanitized request parameters
    query_params = params.except(:page).merge(sort: column, direction: direction, anchor: 'listanchor').permit!
    html_options = { class: css_class, tabindex: 0 }

    link_to [title].join(' ').html_safe, query_params, html_options
  end

  def column_sort_icon
    sort_direction == 'asc' ? "\u25B2" : "\u25BC"
  end

  def dom_id(record, prefix = nil)
    result = ActionView::RecordIdentifier.dom_id(record, prefix)
    if record.is_a?(Claim::BaseClaim) || record.is_a?(Claim::BaseClaimPresenter)
      result.sub!(/claim_((base)|(advocate)|(litigator))_claim/, 'claim')
    end
    result
  end

  def extract_uri_param(path, param)
    CGI.parse(URI.parse(path).query)[param][0]
  rescue NoMethodError
    nil
  end

  def strip_params(path)
    URI.parse(path).path
  rescue URI::Error
    nil
  end

  def your_claims_header
    current_user.persona.admin? ? t('external_users.all_claims') : t('external_users.your_claims')
  end

  def user_requires_scheme_column?
    current_user.persona.has_roles?('admin') || current_user.persona.has_roles?('litigator')
  end

  def title(page_title)
    content_for :page_title, [page_title, 'Claim for crown court defence', 'Gov.uk'].join(' - ')
  end

  def contextual_title
    title [controller_name, action_name].join(' ').titleize
  end

  def show_contact_us_link?
    current_user_persona_is?(ExternalUser) && !defined?(@suppress_contact_us_message)
  end

  def format_phone_number(number)
    # NOTE: right now this is the simpliest formatting possible
    # Not meant to support any fancy functionality until required
    number = number.to_s
    [number[0..3], number[4..6], number[7..10]].join(' ')
  end

  def yes_no_options
    [%w[Yes true], %w[No false]]
  end
end
