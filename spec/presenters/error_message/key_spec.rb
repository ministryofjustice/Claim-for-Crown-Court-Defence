# frozen_string_literal: true

RSpec.shared_examples 'attribute value' do |value|
  it { is_expected.to be_instance_of(described_class) }
  it { is_expected.to eq(value) }
end

RSpec.describe ErrorMessage::Key do
  subject(:error_key) { described_class.new(key) }

  let(:key) { 'foos_attributes_4_bar' }

  it { is_expected.to respond_to :submodel?, :numbered_submodel?, :unnumbered_submodel? }

  describe '.self' do
    subject { error_key }

    let(:key) { 'foos_attributes_4_bar' }

    it { is_expected.to be_a(String) }
    it { is_expected.to eq 'foos_attributes_4_bar' }
  end

  describe '#to_s' do
    subject { error_key.to_s }

    let(:key) { 'foos_attributes_4_bar' }

    it { is_expected.to eq 'foos_attributes_4_bar' }
  end

  describe '#submodel?' do
    subject { error_key.submodel? }

    context 'with numbered submodel key' do
      let(:key) { 'foos_attributes_4_bar' }

      it { is_expected.to be_truthy }
    end

    context 'with unnumbered submodel key' do
      let(:key) { 'foo.bar' }

      it { is_expected.to be_truthy }
    end

    context 'without submodel key' do
      let(:key) { 'bar' }

      it { is_expected.to be_falsey }
    end
  end

  describe '#numbered_submodel?' do
    subject { error_key.numbered_submodel? }

    context 'with numbered submodel key' do
      let(:key) { 'foo_4_bar' }

      it { is_expected.to be_truthy }
    end

    context 'without numbered submodel key' do
      let(:key) { 'foo.bar' }

      it { is_expected.to be_falsey }
    end
  end

  describe '#unnumbered_submodel?' do
    subject { error_key.unnumbered_submodel? }

    context 'with unnumbered submodel key' do
      let(:key) { 'foo.bar' }

      it { is_expected.to be_truthy }
    end

    context 'without unnumbered submodel key' do
      let(:key) { 'foo_1_bar' }

      it { is_expected.to be_falsey }
    end
  end

  describe '#model' do
    subject { error_key.model }

    context 'when single nested' do
      context 'with rails nested error' do
        let(:key) { 'foos_attributes_4_bar' }

        it { is_expected.to eq 'foo' }
      end

      context 'with custom nested errors' do
        let(:key) { 'foo_4_bar' }

        it { is_expected.to eq 'foo' }
      end

      context 'with nested attribute errors' do
        let(:key) { 'foo.bar' }

        it { is_expected.to eq 'foo' }
      end
    end

    context 'when double nested' do
      context 'with rails nested error' do
        let(:key) { 'foos_attributes_4_bars_attributes_1_baz' }

        it { is_expected.to eq 'bar' }
      end

      context 'with custom nested errors' do
        let(:key) { 'foo_4_bar_1_baz' }

        it { is_expected.to eq 'bar' }
      end

      context 'with nested attribute errors' do
        let(:key) { 'foo.bar.baz' }

        it { is_expected.to eq 'bar' }
      end

      context 'with partial nested attribute errors' do
        let(:key) { 'foo.bar_1_baz' }

        it { is_expected.to eq 'bar' }
      end
    end

    context 'when triple nested' do
      context 'with rails nested error' do
        let(:key) { 'foos_attributes_4_bars_attributes_1_bazs_attributes_1_bing' }

        it { is_expected.to eq 'baz' }
      end

      context 'with custom nested errors' do
        let(:key) { 'foo_4_bar_1_baz_1_bing' }

        it { is_expected.to eq 'baz' }
      end

      context 'with nested attribute errors' do
        let(:key) { 'foo.bar.baz.bing' }

        it { is_expected.to eq 'baz' }
      end

      context 'with partial nested attribute errors' do
        let(:key) { 'foo.bar_1_baz_1_bing' }

        it { is_expected.to eq 'baz' }
      end
    end
  end

  describe '#attribute' do
    subject { error_key.attribute }

    context 'when single nested' do
      context 'with rails nested error' do
        let(:key) { 'foos_attributes_4_bar' }

        include_examples 'attribute value', 'bar'
      end

      context 'with custom nested errors' do
        let(:key) { 'foo_4_bar' }

        include_examples 'attribute value', 'bar'
      end

      context 'with nested attribute errors' do
        let(:key) { 'foo.bar' }

        include_examples 'attribute value', 'bar'
      end
    end

    context 'when double nested' do
      context 'with rails nested error' do
        let(:key) { 'foos_attributes_4_bars_attributes_1_baz' }

        include_examples 'attribute value', 'baz'
      end

      context 'with custom nested errors' do
        let(:key) { 'foo_4_bar_1_baz' }

        include_examples 'attribute value', 'baz'
      end

      context 'with nested attribute errors' do
        let(:key) { 'foo.bar.baz' }

        include_examples 'attribute value', 'baz'
      end

      context 'with partial nested attribute errors' do
        let(:key) { 'foo.bar_1_baz' }

        include_examples 'attribute value', 'baz'
      end
    end

    context 'when triple nested' do
      context 'with rails nested error' do
        let(:key) { 'foos_attributes_4_bars_attributes_1_bazs_attributes_1_bing' }

        include_examples 'attribute value', 'bing'
      end

      context 'with custom nested errors' do
        let(:key) { 'foo_4_bar_1_baz_1_bing' }

        include_examples 'attribute value', 'bing'
      end

      context 'with nested attribute errors' do
        let(:key) { 'foo.bar.baz.bing' }

        include_examples 'attribute value', 'bing'
      end

      context 'with partial nested attribute errors' do
        let(:key) { 'foo.bar_1_baz_1_bing' }

        include_examples 'attribute value', 'bing'
      end
    end
  end

  describe '#all_model_indices' do
    subject { error_key.all_model_indices }

    context 'when single nested' do
      context 'with rails nested error' do
        let(:key) { 'foos_attributes_4_bar' }

        it { is_expected.to eq({ 'foo' => '4' }) }
      end

      context 'with custom nested errors' do
        let(:key) { 'foo_4_bar' }

        it { is_expected.to eq({ 'foo' => '4' }) }
      end

      context 'with nested attribute errors' do
        let(:key) { 'foo.bar' }

        it { is_expected.to eq({ 'foo' => '0' }) }
      end
    end

    context 'when double nested' do
      context 'with rails nested error' do
        let(:key) { 'foos_attributes_4_bars_attributes_1_baz' }

        it { is_expected.to eq({ 'foo' => '4', 'bar' => '1' }) }
      end

      context 'with custom nested errors' do
        let(:key) { 'foo_4_bar_1_baz' }

        it { is_expected.to eq({ 'foo' => '4', 'bar' => '1' }) }
      end

      context 'with nested attribute errors' do
        let(:key) { 'foo.bar.baz' }

        it { is_expected.to eq({ 'foo' => '0', 'bar' => '0' }) }
      end

      context 'with partial nested attribute errors' do
        let(:key) { 'foo.bar_1_baz' }

        it { is_expected.to eq({ 'foo' => '0', 'bar' => '0' }) }
      end
    end

    context 'when triple nested' do
      context 'with rails nested error' do
        let(:key) { 'foos_attributes_4_bars_attributes_1_bazs_attributes_1_bing' }

        it { is_expected.to eq({ 'foo' => '4', 'bar' => '1', 'baz' => '1' }) }
      end

      context 'with custom nested errors' do
        let(:key) { 'foo_4_bar_1_baz_1_bing' }

        it { is_expected.to eq({ 'foo' => '4', 'bar' => '1', 'baz' => '1' }) }
      end

      context 'with nested attribute errors' do
        let(:key) { 'foo.bar.baz.bing' }

        it { is_expected.to eq({ 'foo' => '0', 'bar' => '0', 'baz' => '0' }) }
      end

      context 'with partial nested attribute errors' do
        let(:key) { 'foo.bar_1_baz_1_bing' }

        it { is_expected.to eq({ 'foo' => '0', 'bar' => '0', 'baz' => '0' }) }
      end
    end
  end
end
