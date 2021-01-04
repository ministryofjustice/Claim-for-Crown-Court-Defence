require 'rails_helper'

describe Fee::InterimFeeTypePresenter do
  describe '#data_attributes' do
    let(:presenter) { Fee::InterimFeeTypePresenter.new(fee_type, view) }

    context 'disbursement only' do
      let(:fee_type) { build :interim_fee_type, :disbursement_only }
      it 'produces expected data attributes' do
        expect(presenter.data_attributes).to eq expected_data(false, false, false, false, false, false, false, false, true)
      end
    end

    context 'effective_pcmh' do
      let(:fee_type) { build :interim_fee_type, :effective_pcmh }
      it 'produces expected data attributes' do
        expect(presenter.data_attributes).to eq expected_data(true, false, false, false, false, true, true, false, true)
      end
    end

    context 'retrial new solicitor' do
      let(:fee_type) { build :interim_fee_type, :retrial_new_solicitor }
      it 'produces expected data attributes' do
        expect(presenter.data_attributes).to eq expected_data(false, false, true, true, false, true, true, false, true)
      end
    end

    context 'retrial start' do
      let(:fee_type) { build :interim_fee_type, :retrial_start }
      it 'produces expected data attributes' do
        expect(presenter.data_attributes).to eq expected_data(false, false, false, false, true, true, true, false, true)
      end
    end

    context 'trial start' do
      let(:fee_type) { build :interim_fee_type, :trial_start }
      it 'produces expected data attributes' do
        expect(presenter.data_attributes).to eq expected_data(false, true, false, false, false, true, true, false, true)
      end
    end

    context 'warrant'do
      let(:fee_type) { build :interim_fee_type, :warrant }
      it 'produces expected data attributes' do
        expect(presenter.data_attributes).to eq expected_data(false, false, false, false, false, false, true, true, false)
      end
    end
  end

  def expected_data(epcmh, trial_dates, lat, tcon, retrial, ppe, total, warrant, disb)
    {
        effective_pcmh: epcmh,
        trial_dates: trial_dates,
        legal_aid_transfer: lat,
        trial_concluded: tcon,
        retrial_dates: retrial,
        ppe: ppe,
        fee_total: total,
        warrant: warrant,
        disbursements: disb
    }
  end
end
