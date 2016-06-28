module Stats
  module GeckoWidgets
    class LineGraph

      def initialize
        @datasets = {}
        @series = []
        @dataset_size = nil
      end

      def add_dataset(name, dataset)
        @datasets[name] = dataset
        @dataset_size = dataset.size
      end

      def to_json
        generate_array_of_series
        {
          'x_axis' => {
            'labels' => make_x_axis_labels
          },
          'series' => @series
        }.to_json
      end

      private
      def generate_array_of_series
        @datasets.each do |name, dataset|
          @series << { 'name' => name, 'data' => dataset }
        end
      end

      def make_x_axis_labels
        range = @dataset_size * -1 .. -1
        range.to_a
      end

    end
  end
end