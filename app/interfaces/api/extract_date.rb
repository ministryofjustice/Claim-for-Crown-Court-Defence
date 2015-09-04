module API
  module ExtractDate
    def extract_date(unit, param)
      if param.present?
        case unit
        when :day
          param.slice(8..9)
        when :month
          param.slice(5..6)
        when :year
          param.slice(0..3)
        end
      end
    end
  end
end