require 'rails_helper'

describe Fee::InterimFeePresenter do

  let(:interim_fee) { instance_double(Fee::InterimFee, claim: double) }
  let(:presenter) { Fee::InterimFeePresenter.new(interim_fee, view) }

  context 'retrieves fields from the claim' do
    [:effective_pcmh_date, :first_day_of_trial, :retrial_started_at, :trial_concluded_at,
     :legal_aid_transfer_date, :estimated_trial_length, :retrial_estimated_length].each do |field|
      it "retrieves #{field} from the claim" do
        expect(interim_fee.claim).to receive(field)
        presenter.send(field)
      end
    end
  end

  context '#rate' do
    it 'should call not_applicable' do
      expect(presenter).to receive(:not_applicable)
      presenter.rate
    end
  end

  context '#quantity' do
    it 'should return fee quantity for all interim fees except interim warrants' do
      allow(interim_fee).to receive(:is_interim_warrant?).and_return false
      expect(interim_fee).to receive(:quantity)
      presenter.quantity
    end

    it 'should return not_applicable for interim warrants' do
      allow(interim_fee).to receive(:is_interim_warrant?).and_return true
      expect(presenter).to receive(:not_applicable)
      presenter.quantity
    end
  end

end
