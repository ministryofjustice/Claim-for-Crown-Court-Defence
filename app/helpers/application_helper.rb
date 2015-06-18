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

end
