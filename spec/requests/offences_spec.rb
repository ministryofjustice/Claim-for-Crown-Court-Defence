require 'rails_helper'

RSpec.describe 'offences details' do
  describe 'GET index' do
    subject(:get_offences) { get offences_url, params:, xhr: true }

    let(:json) { response.parsed_body }

    before do
      # Scheme 9 offences
      create(
        :offence,
        :with_fee_scheme,
        description: 'Offence 1',
        offence_class: create(:offence_class, id: 2, description: 'Offence class 1')
      )
      create(
        :offence,
        :with_fee_scheme,
        description: 'Offence 3',
        offence_class: create(:offence_class, id: 4, description: 'Offence class 2')
      )
      create(
        :offence,
        :with_fee_scheme,
        description: 'Offence 2',
        offence_class: create(:offence_class, id: 8, description: 'Offence class 3')
      )

      # Scheme 10 offences
      create(:offence, :with_fee_scheme_ten, description: 'Offence 10-1')
      create(:offence, :with_fee_scheme_ten, description: 'Offence 10-3')
      create(:offence, :with_fee_scheme_ten, description: 'Offence 10-2')
    end

    context 'with no parameters' do
      let(:params) { nil }

      before { get_offences }

      it 'returns all offences in the default scheme (scheme 9)' do
        expect(json.pluck('description')).to eq(['Offence 1', 'Offence 2', 'Offence 3'])
      end

      it 'returns the offence class' do
        expect(json.pick('offence_class'))
          .to include('id' => 2, 'description' => 'Offence class 1')
      end
    end

    context 'with an offence description' do
      let(:params) { { description: 'Offence 3' } }

      before { get_offences }

      it 'just gets the matching offence' do
        expect(json.pluck('description')).to eq(['Offence 3'])
      end
    end

    context 'when fee reform filter is provided' do
      let(:params) { { fee_scheme: 'AGFS 10' } }
      let(:expected_params) { ActionController::Parameters.new(fee_scheme: 'AGFS 10').permit(:fee_scheme) }

      before do
        allow(FeeReform::SearchOffences).to receive(:call).and_call_original
        get_offences
      end

      it 'returns offences only for fee scheme 10' do
        expect(json.pluck('description')).to contain_exactly('Offence 10-1', 'Offence 10-3', 'Offence 10-2')
      end

      it 'calls the fee reform search offences service with the provided filters' do
        expect(FeeReform::SearchOffences).to have_received(:call).with(expected_params)
      end
    end
  end
end
