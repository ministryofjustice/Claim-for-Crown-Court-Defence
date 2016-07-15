module Stats
  module GeckoWidgets
    class LineGraph

      attr_reader :dataset_size

      attr_writer :x_axis_labels

      def initialize
        @datasets = {}
        @series = []
        @dataset_size = nil
        @x_axis_labels = nil
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
            'labels' => (@x_axis_labels || make_x_axis_labels)
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
          row << label_column(i)
          dataset_names.each do |dataset_name|
            row << @datasets[dataset_name][i]
          end
          array << row
        end
        array
      end



      private

      def label_column(i)
        if @x_axis_labels.nil?
          (Date.today - (@dataset_size - i).days).strftime('%a %d %b %Y')
        else
          @x_axis_labels[i]
        end
      end


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