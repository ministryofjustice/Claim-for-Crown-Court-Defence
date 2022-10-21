require 'rails_helper'

module Claims
  describe ValueBands do
    describe '.band_id_for_claim' do
      subject(:band_id_for_claim) { described_class.band_id_for_claim(claim) }

      context 'with a band 10 claim with VAT' do
        let(:claim) { instance_double(Claim::BaseClaim, total: 23_000.77, vat_amount: 6_999.23) }

        it { is_expected.to eq 10 }
      end

      context 'with a band 20 claim with VAT' do
        let(:claim) { instance_double(Claim::BaseClaim, total: 23_000.77, vat_amount: 6_999.24) }

        it { is_expected.to eq 20 }
      end

      context 'with a band 30 claim with VAT' do
        let(:claim) { instance_double(Claim::BaseClaim, total: 145_000.0, vat_amount: 30_000) }

        it { is_expected.to eq 30 }
      end

      context 'with a band 40 claim with VAT' do
        let(:claim) { instance_double(Claim::BaseClaim, total: 145_000.0, vat_amount: 30_000.02) }

        it { is_expected.to eq 40 }
      end

      context 'with a claim over the limit with VAT' do
        let(:claim) { instance_double(Claim::BaseClaim, total: 99_999_999.0, vat_amount: 9_999.0) }

        it { expect { band_id_for_claim }.to raise_error 'Maximum band value exceeded' }
      end

      context 'with a band 10 claim without VAT' do
        let(:claim) { instance_double(Claim::BaseClaim, total: 30_000.00, vat_amount: 0.0) }

        it { is_expected.to eq 10 }
      end

      context 'with a band 20 claim without VAT' do
        let(:claim) { instance_double(Claim::BaseClaim, total: 30_000.01, vat_amount: 0.0) }

        it { is_expected.to eq 20 }
      end

      context 'with a band 30 claim without VAT' do
        let(:claim) { instance_double(Claim::BaseClaim, total: 175_000.0, vat_amount: 0.0) }

        it { is_expected.to eq 30 }
      end

      context 'with a band 40 claim without VAT' do
        let(:claim) { instance_double(Claim::BaseClaim, total: 175_000.01, vat_amount: 0.0) }

        it { is_expected.to eq 40 }
      end

      context 'with a claim over the limit without VAT' do
        let(:claim) { instance_double(Claim::BaseClaim, total: 100_000_000, vat_amount: 0.0) }

        it { expect { band_id_for_claim }.to raise_error 'Maximum band value exceeded' }
      end
    end

    describe '.band_by_id' do
      subject(:band) { described_class.band_by_id(20) }

      it 'returns the ValueBandDefinition struct for the given id' do
        expect(band.name).to eq '£30,000.01 - £115,000'
      end
    end

    describe '.bands' do
      subject(:bands) { described_class.bands }

      it { expect(bands.map(&:id)).to eq([10, 20, 30, 40]) }
    end

    describe '.band_ids' do
      subject { described_class.band_ids }

      it { is_expected.to eq([10, 20, 30, 40]) }
    end

    describe '.collection_select' do
      subject(:collection_select) { described_class.collection_select }

      it { expect(collection_select.map(&:id)).to eq([0, 10, 20, 30, 40]) }
      it { expect(collection_select.first.name).to eq('All Claims') }
    end
  end
end
