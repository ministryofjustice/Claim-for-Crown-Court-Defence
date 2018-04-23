module API
  module V2
    module MIHelper
      extend Grape::API::Helpers

      def start_and_end_from(date)
        if date.nil?
          start_date = Date.new(2018, 4, 1).beginning_of_day
          end_date = Date.yesterday.end_of_day
        else
          start_date = params[:date].to_date.beginning_of_day
          end_date = params[:date].to_date.end_of_day
        end
        [start_date, end_date]
      end

      def build_csv_from(data)
        CSV.generate do |build_csv|
          fields = data.first.keys
          build_csv << fields
          data.each do |row|
            build_csv << row.values
          end
        end
      end
    end
  end
end
