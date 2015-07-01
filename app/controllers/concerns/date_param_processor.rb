module DateParamProcessor
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::MultiparameterAssignmentErrors do
      process_date_params
      send(params[:action])
    end
  end

  module ClassMethods
    attr_reader :date_fields

    def date_field_params(*fields)
      @date_fields = fields
    end
  end

  private

  def process_date_params
    self.class.date_fields.each do |field|
      month = month(field)
      parsed_month = parse_month(month)
      params[object_name]["#{field}(2i)"] = parsed_month
    end
  end

  def day(field)
    params[object_name]["#{field}(3i)"]
  end

  def month(field)
    params[object_name]["#{field}(2i)"]
  end

  def year(field)
    params[object_name]["#{field}(3i)"]
  end

  def parse_month(month)
    if %w(jan feb mar apr may jun jul aug sep oct nov dec).include?(month.downcase)
      month.capitalize.to_date.strftime('%m')
    else
      month
    end
  end

  def object_name
    controller_name.classify.downcase
  end
end
