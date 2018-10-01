class BasePresenter < SimpleDelegator
  include ActionView::Helpers::TextHelper

  def initialize(model, view)
    @model = model
    @view = view
    super(@model)
  end

  def self.presents(name)
    define_method(name) do
      @model
    end
  end

  private_class_method :presents

  def format_date(date)
    date&.strftime(Settings.date_format)
  end

  def date_format(options = {})
    options.assert_valid_keys(:include_time)
    options[:include_time] ? Settings.date_time_format : Settings.date_format
  end

  private

  attr_reader :view
  alias h view

  delegate :t, to: :view
end
