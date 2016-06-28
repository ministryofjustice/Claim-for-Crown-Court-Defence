module Stats
  module GeckoWidgets
    class LineGraph

      def initialize(title)
        @datasets = {}
        @series = []
      end

      def add_dataset(name, dataset)
        @datasets[name] = dataset
      end

      def to_json
        generate_array_of_series
        {
          'series' => @series
        }.to_json
      end

      private
      def generate_array_of_series
        @datasets.each do |name, dataset|
          @series << { 'name' => name, 'data' => dataset }
        end
      end

    end
  end
end