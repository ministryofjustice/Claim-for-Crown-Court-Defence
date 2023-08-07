require 'rails_helper'

RSpec.describe CCR::AdvocateCategoryAdapter, type: :adapter do
  describe '.code_for' do
    subject { described_class.code_for(advocate_category) }

    context 'with KC' do
      let(:advocate_category) { 'KC' }

      it { is_expected.to eq 'KC' }
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
