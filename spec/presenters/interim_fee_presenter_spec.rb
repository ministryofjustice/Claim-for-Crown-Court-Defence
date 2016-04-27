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
end
