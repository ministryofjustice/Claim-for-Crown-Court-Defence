module ApplicationHelper

  #
  # Can be called in views in order to instantiate a presenter for a partilcular model
  # following the <Model>Presenter naming convention or, optionally, a name presenter
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

  def number_with_precision_or_blank(number, options = {})
    if options.has_key?(:precision)
      number == 0 ? '' : number_with_precision(number, options)
    else
      number == 0 ? '' : number.to_s
    end
  end

end
