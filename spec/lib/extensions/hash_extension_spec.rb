require 'rails_helper'

RSpec.describe Hash do
  let(:h) do
    {
      key_id: '1',
      hash1: { key_id: '2' },
      array1: [
        { key_id: '3' },
        { key_id: '4' }
      ],
      array2: [
        { hash2:
          { key_id: '5' },
          array3: [key_id: '6']
        },
        hash3:
          {
            key_id: { key_id: '7' }
          }
      ],
      array4: [
        {
          key_id: [:key_id, :key_id]
        }
      ]
    }
  end

  describe '#all_values_for' do
    subject { h.all_values_for(:key_id) }

    it 'returns an array of all values for the specified key' do
      is_expected.to match_array ['1', '2', '3', '4', '5', '6', { :key_id => '7' }, '7', [:key_id, :key_id]]
    end
  end

  describe '#all_keys' do
    subject(:result) { h.all_keys }

    it 'returns an array of all keys' do
      is_expected.to match_array [:array1, :array2, :array3, :array4, :hash1, :hash2, :hash3, :key_id, :key_id, :key_id, :key_id, :key_id, :key_id, :key_id, :key_id, :key_id]
    end

    it 'returns duplicate keys' do
      expect(result.select { |el| el.eql?(:key_id) }.size).to be_eql 9
    end
  end
end
