require 'rails_helper'

RSpec.describe 'offences details', type: :request do
  before do
    # Scheme 9 offences
    create(:offence, :with_fee_scheme, description: 'Offence 1')
    create(:offence, :with_fee_scheme, description: 'Offence 3')
    create(:offence, :with_fee_scheme, description: 'Offence 2')

    # Scheme 10 offences
    create(:offence, :with_fee_scheme_ten, description: 'Offence 10-1')
    create(:offence, :with_fee_scheme_ten, description: 'Offence 10-3')
    create(:offence, :with_fee_scheme_ten, description: 'Offence 10-2')
  end

  describe 'GET index' do
    subject(:get_offences) { get offences_url, params: params, xhr: true }

    context 'with no parameters' do
      let(:params) { nil }

      before { get_offences }

      it 'returns all offences if no description present' do
        expect(assigns(:offences).map(&:description)).to eq(['Offence 1', 'Offence 2', 'Offence 3'])
      end
    end

    context 'with an offence description' do
      let(:params) { { description: 'Offence 3' } }

      before { get_offences }

      it 'just gets the matching offence' do
        expect(assigns(:offences).map(&:description)).to eq(['Offence 3'])
      end
    end

    context 'when fee reform filter is provided' do
      let(:params) { { fee_scheme: 'AGFS 10' } }

      before do
        allow(FeeReform::SearchOffences).to receive(:call).and_call_original
        get_offences
      end

      it 'returns offences only for fee scheme 10' do
        expect(assigns(:offences).map(&:description)).to match_array(['Offence 10-1', 'Offence 10-3', 'Offence 10-2'])
      end

      it 'calls the fee reform search offences service with the provided filters' do
        expect(FeeReform::SearchOffences).to have_received(:call).with('fee_scheme' => 'AGFS 10')
      end
    end
  end
end
