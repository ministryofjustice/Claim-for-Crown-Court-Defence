module DateParamProcessor
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::MultiparameterAssignmentErrors do
      puts ">>>>>>>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
      process_date_params
      send(params[:action])
    end
  end

  private

  def process_date_params
    parse_months(params[object_name])
  end

  def parse_months(params)
    params.each do |key, value|
      parse_months(params[key]) if value.is_a?(Hash)
      params[key] = parse_month(value) if key =~ /\(2i\)/
    end
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
