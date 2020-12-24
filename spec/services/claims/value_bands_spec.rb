require 'rails_helper'

module Claims

  describe ValueBands do
    describe '.band_id_for_claim' do
      context 'with VAT' do
        it 'returns band 10' do
          claim = double(Claim, total: 18_000.77, vat_amount: 6_999.23)
          expect(ValueBands.band_id_for_claim(claim)).to eq 10
        end

        it 'returns band 20' do
          claim = double(Claim, total: 18_000.77, vat_amount: 6_999.24)
          expect(ValueBands.band_id_for_claim(claim)).to eq 20
        end

        it 'returns band 30' do
          claim = double(Claim, total: 120_000.00, vat_amount: 30_000)
          expect(ValueBands.band_id_for_claim(claim)).to eq 30
        end

        it 'returns band 40' do
          claim = double(Claim, total: 120_000.00, vat_amount: 30_000.02)
          expect(ValueBands.band_id_for_claim(claim)).to eq 40
        end

        it 'raises if over maximum limit' do
          claim = double(Claim, total: 99_999_999.0, vat_amount: 9_000.0)
          expect {
            ValueBands.band_id_for_claim(claim)
          }.to raise_error 'Maximum band value exceeded'
        end
      end

      context 'without VAT' do
        it 'returns band 10' do
          claim = double(Claim, total: 25_000.00, vat_amount: 0.0)
          expect(ValueBands.band_id_for_claim(claim)).to eq 10
        end

        it 'returns band 20' do
          claim = double(Claim, total: 25_000.01, vat_amount: 0.0)
          expect(ValueBands.band_id_for_claim(claim)).to eq 20
        end

        it 'returns band 30' do
          claim = double(Claim, total: 150_000.0, vat_amount: 0.0)
          expect(ValueBands.band_id_for_claim(claim)).to eq 30
        end

        it 'returns band 40' do
          claim = double(Claim, total: 150_000.01, vat_amount: 0.0)
          expect(ValueBands.band_id_for_claim(claim)).to eq 40
        end
      end
    end

    describe '.band_by_id' do
      it 'returns the ValueBandDefinition struct for the given id' do
        band = ValueBands.band_by_id(20)
        expect(band.name).to eq '£25,001 - £100,000'
        expect(band.min).to eq 25_000.01
        expect(band.max).to eq 100_000.0
      end
    end

    describe '.bands' do
      it 'returns an array of bands in ascending order' do
        bands = ValueBands.bands
        expect(bands.size).to eq 4
        expect(bands.map(&:id)).to eq([10, 20, 30, 40])
      end
    end

    describe '.band_ids' do
      it 'returns a list of band ids' do
        expect(ValueBands.band_ids).to eq([10, 20, 30, 40])
      end
    end

    describe '.collection_select' do
      it 'returns an array of Bands including a dummy on for all bands' do
        bands = ValueBands.collection_select
        expect(bands.size).to eq 5
        expect(bands.map(&:id)).to eq([0, 10, 20, 30, 40])
        expect(bands.first.name).to eq 'All Claims'
      end
    end
  end
end
