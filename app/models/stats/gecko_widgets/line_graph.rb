module Stats
  module GeckoWidgets
    class LineGraph

      attr_reader :dataset_size

      def initialize
        @datasets = {}
        @series = []
        @dataset_size = nil
      end

      def add_dataset(name, dataset)
        @datasets[name] = dataset
        @dataset_size = dataset.size
      end

      # return a json structure in the format suitable for generating a Geckoboard Line graph widget
      def to_json
        generate_array_of_series
        {
          'x_axis' => {
            'labels' => make_x_axis_labels
          },
          'series' => @series
        }.to_json
      end

      def dataset_names
        @datasets.keys
      end

      # return an array of arrays suitable for representing the data in an HTML table
      def to_a
        array = []
        (0..@dataset_size - 1).each do |i|
          row = []
          row << (Date.today - (@dataset_size - i).days).strftime('%a %d %b %Y')
          dataset_names.each do |dataset_name|
            row << @datasets[dataset_name][i]
          end
          array << row
        end
        array
      end



      private

      def generate_array_of_series
        @datasets.each do |name, dataset|
          @series << { 'name' => name, 'data' => dataset }
        end
      end

      def make_x_axis_labels
        range = @dataset_size * -1..-1
        range.to_a.collect(&:to_s)
      end

    end
  end
end