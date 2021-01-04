require 'rails_helper'

module Stats
  module GeckoWidgets

    describe 'LineGraph' do
      before(:each) do
        @lg = LineGraph.new
        @lg.add_dataset('Tories', [33, 5, 6])
        @lg.add_dataset('Labour', [22, 24, 9])
        @lg.add_dataset('LibDems', [5, 8, 14])
      end

      describe '#dataaset_names' do
        it 'should return an array of dataset names in the order they were added' do
          expect(@lg.dataset_names).to eq %w{Tories Labour LibDems}
        end
      end

      describe '#dataset size' do
        it 'should return the number of entries in the data series' do
          expect(@lg.dataset_size).to eq 3
        end
      end

      describe '#to_json' do
        context 'without specifying x-axis labels' do
          it 'should preoduce a json structure suitable for generating a Geckoboard Line graph widget' do
            data = {
              'x_axis' => { 'labels' => %w(-3 -2 -1) },
              'series' => [
                {
                  'name' => 'Tories',
                  'data' => [33, 5, 6]
                },
                {
                  'name' => 'Labour',
                  'data' => [22, 24, 9]
                },
                {
                  'name' => 'LibDems',
                  'data' => [5, 8, 14]
                }
              ]
            }
            expect(@lg.to_json).to eq data.to_json
          end
        end

        context 'with specifying custom x-axis labels' do
          it 'should preoduce a json structure suitable for generating a Geckoboard Line graph widget' do
            @lg.x_axis_labels = %w{Jan Feb Mar}
            data = {
              'x_axis' => { 'labels' => %w(Jan Feb Mar) },
              'series' => [
                {
                  'name' => 'Tories',
                  'data' => [33, 5, 6]
                },
                {
                  'name' => 'Labour',
                  'data' => [22, 24, 9]
                },
                {
                  'name' => 'LibDems',
                  'data' => [5, 8, 14]
                }
              ]
            }
            expect(@lg.to_json).to eq data.to_json
          end
        end
      end

      describe '#to_a' do
        context 'without specifying x-axis labels' do
          it 'should produce an array of arrays suitable for displaying in a tabular format' do
            travel_to(Date.new(2016, 7, 13)) do
              array = [
                ['Sun 10 Jul 2016', 33, 22, 5],
                ['Mon 11 Jul 2016', 5, 24, 8],
                ['Tue 12 Jul 2016', 6, 9, 14]
              ]
              expect(@lg.to_a).to eq array
            end
          end
        end

        context 'specifying custom x-axis labels' do
          it 'should produce an array of arrays suitable for displaying in a tabular format' do
            @lg.x_axis_labels = %w{Jan Feb Mar}
            array = [
              ['Jan', 33, 22, 5],
              ['Feb', 5, 24, 8],
              ['Mar', 6, 9, 14]
            ]
            expect(@lg.to_a).to eq array
          end
        end
      end
    end
  end
end
