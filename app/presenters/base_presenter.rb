class BasePresenter < SimpleDelegator
  include ActionView::Helpers::TextHelper

  def initialize(model, view)
    @model, @view = model, view
    super(@model)
  end


  def self.presents(name)
    define_method(name) do
      @model
    end
  end

  private_class_method :presents

  def format_date(date)
    date.strftime(Settings.date_format) rescue nil
  end

  def date_format(options={})
    options.assert_valid_keys(:include_time)
    options[:include_time] ? Settings.date_time_format : Settings.date_format
  end

  private

  def h
    @view
  end
end
