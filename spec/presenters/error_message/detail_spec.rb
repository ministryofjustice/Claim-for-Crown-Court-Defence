# frozen_string_literal: true

RSpec.describe ErrorMessage::Detail do
  subject { described_class.new(:attribute_one, 'long', 'short', 'api') }

  it { is_expected.to respond_to(:attribute, :long_message, :short_message, :api_message, :sequence) }

  describe '#sequence' do
    subject { detail.sequence }

    context 'when sequence specified' do
      let(:detail) { described_class.new(:attribute_one, 'long', 'short', 'api', 15) }

      it { is_expected.to eq(15) }
    end

    context 'when sequence not specified' do
      let(:detail) { described_class.new(:attribute_one, 'long', 'short', 'api') }

      it { is_expected.to eq(99999) }
    end
  end

  describe '#<=>' do
    let(:first_detail) { described_class.new(:attribute_one, 'long', 'short', 'api', 9) }
    let(:middle_detail) { described_class.new(:attribute_one, 'long', 'short', 'api', 10) }
    let(:last_detail) { described_class.new(:attribute_two, 'long', 'short', 'api', 11) }

    it 'sorts by sequence ascending' do
      expect([middle_detail, last_detail, first_detail].sort!).to eql([first_detail, middle_detail, last_detail])
    end
  end

  describe '#==' do
    context 'when comparing detail object with non-detail object' do
      let(:detail_object) { described_class.new(:key3, 'long', 'short', 'api') }
      let(:other_object) { 'not an ErrorDetail' }

      it { expect(detail_object).not_to eq(other_object) }
    end

    context 'when comparing detail object with detail object' do
      context 'with attribute, long_message, short_message and api_message equal' do
        let(:detail_one) { described_class.new(:attribute_one, 'long', 'short', 'api') }
        let(:detail_two) { described_class.new(:attribute_one, 'long', 'short', 'api') }

        specify { expect(detail_one).to eq(detail_two) }
      end

      context 'with all but attribute different' do
        let(:detail_one) { described_class.new(:attribute_one, 'long', 'short', 'api') }
        let(:detail_two) { described_class.new(:attribute_two, 'long', 'short', 'api') }

        specify { expect(detail_one).not_to eq(detail_two) }
      end

      context 'with all but long_message different' do
        let(:detail_one) { described_class.new(:attribute_one, 'long', 'short', 'api') }
        let(:detail_two) { described_class.new(:attribute_one, 'different', 'short', 'api') }

        specify { expect(detail_one).not_to eq(detail_two) }
      end

      context 'with all but short_message different' do
        let(:detail_one) { described_class.new(:attribute_one, 'long', 'short', 'api') }
        let(:detail_two) { described_class.new(:attribute_one, 'long', 'different', 'api') }

        specify { expect(detail_one).not_to eq(detail_two) }
      end

      context 'with all but api_message different' do
        let(:detail_one) { described_class.new(:attribute_one, 'long', 'short', 'api') }
        let(:detail_two) { described_class.new(:attribute_one, 'long', 'short', 'different') }

        specify { expect(detail_one).not_to eq(detail_two) }
      end
    end
  end

  describe '#to_summary_error' do
    subject { detail.to_summary_error }

    let(:detail) { described_class.new(:attribute_one, 'long', 'short', 'api') }

    it { is_expected.to be_an(Array) }
    it { is_expected.to eq([:attribute_one, 'long']) }
  end
end
