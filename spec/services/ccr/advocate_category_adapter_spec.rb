require 'rails_helper'

RSpec.describe CCR::AdvocateCategoryAdapter, type: :adapter do
  describe '.code_for' do
    subject { described_class.code_for(advocate_category) }

    context 'with KC' do
      let(:advocate_category) { 'KC' }

      context 'when can_inject_kc is true' do
        before do
          allow(Settings).to receive(:can_inject_kc).and_return(true)
          load Rails.root.join('app', 'services', 'ccr', 'advocate_category_adapter.rb')
        end

        it { is_expected.to eq 'KC' }
      end

      context 'when can_inject_kc is false' do
        before do
          allow(Settings).to receive(:can_inject_kc).and_return(false)
          load Rails.root.join('app', 'services', 'ccr', 'advocate_category_adapter.rb')
        end

        it { is_expected.to eq 'QC' }
      end
    end

    context 'with QC' do
      let(:advocate_category) { 'QC' }

      it { is_expected.to eq 'QC' }
    end

    context 'with Led junior' do
      let(:advocate_category) { 'Led junior' }

      it { is_expected.to eq 'LEDJR' }
    end

    context 'with Leading junior' do
      let(:advocate_category) { 'Leading junior' }

      it { is_expected.to eq 'LEADJR' }
    end

    context 'with Junior alone' do
      let(:advocate_category) { 'Junior alone' }

      it { is_expected.to eq 'JRALONE' }
    end

    context 'with Junior' do
      let(:advocate_category) { 'Junior' }

      it { is_expected.to eq 'JUNIOR' }
    end
  end
end
