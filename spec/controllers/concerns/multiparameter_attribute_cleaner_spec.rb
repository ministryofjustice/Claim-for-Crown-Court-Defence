RSpec.describe MultiparameterAttributeCleaner do
  let(:person_params) do
    {
      person: {
        name: 'Joe Bloggs',
        'date_of_birth(1i)' => '1987',
        'date_of_birth(2i)' => mm,
        'date_of_birth(3i)' => dd
      }
    }
  end

  let(:mm) { '12' }
  let(:dd) { '31' }

  described_class.tap do |described_mod|
    controller(ActionController::Base) do
      include described_mod
    end
  end

  it 'mixes in expected methods' do
    expect(controller).to respond_to(:clean_multiparameter_dates)
  end

  context 'without before_action to call clean_multiparameter_dates' do
    described_class.tap do |described_mod|
      controller(ActionController::Base) do
        include described_mod

        def create
          render json: person_params.to_json
        end

        def person_params
          params.require(:person).permit(:date_of_birth)
        end
      end
    end

    context 'with valid date parts' do
      it 'does not change parameters' do
        post :create, params: person_params
        expect(JSON.parse(response.body))
          .to include({ 'date_of_birth(3i)' => '31', 'date_of_birth(2i)' => '12' })
      end
    end

    context 'with invalid date parts' do
      let(:mm) { '13' }
      let(:dd) { '32' }

      it 'does not change parameters' do
        post :create, params: person_params
        expect(JSON.parse(response.body))
          .to include({ 'date_of_birth(3i)' => '32', 'date_of_birth(2i)' => '13' })
      end
    end
  end

  context 'with before_action to call clean_multiparameter_dates' do
    described_class.tap do |described_mod|
      controller(ActionController::Base) do
        include described_mod

        before_action :clean_multiparameter_dates, only: :create

        def create
          render json: person_params.to_json
        end

        def person_params
          params.require(:person).permit(
            :name,
            :date_of_birth,
            address_attributes: [:address1,
                                 :moved_in,
                                 { previous_address: [:prevaddress1,
                                                      :moved_out] }]
          )
        end
      end
    end

    it 'controller calls the cleaner once' do
      allow(controller).to receive(:clean_multiparameter_dates)
      post :create, params: person_params
      expect(controller).to have_received(:clean_multiparameter_dates).once
    end

    context 'with valid date parts' do
      let(:mm) { '12' }
      let(:dd) { '31' }

      it 'does not change params' do
        post :create, params: person_params
        expect(JSON.parse(response.body))
          .to include({ 'date_of_birth(3i)' => '31', 'date_of_birth(2i)' => '12' })
      end
    end

    context 'with invalid date parts' do
      let(:mm) { '13' }
      let(:dd) { '32' }

      it 'clears invalid day and month values' do
        post :create, params: person_params
        expect(JSON.parse(response.body))
          .to include({ 'date_of_birth(3i)' => '', 'date_of_birth(2i)' => '' })
      end
    end

    context 'with valid nested attribute date parts' do
      let(:person_params) do
        { person: { 'name' => 'Joe Bloggs',
                    'date_of_birth(1i)' => '1987',
                    'date_of_birth(2i)' => '01',
                    'date_of_birth(3i)' => '01',
                    'address_attributes' => { '0' => { 'address1' => 'wherever',
                                                       'moved_in(1i)' => '1987',
                                                       'moved_in(2i)' => '01',
                                                       'moved_in(3i)' => '01' } } } }
      end

      let(:expected_response) do
        { 'name' => 'Joe Bloggs',
          'date_of_birth(1i)' => '1987',
          'date_of_birth(2i)' => '01',
          'date_of_birth(3i)' => '01',
          'address_attributes' => { '0' => { 'address1' => 'wherever',
                                             'moved_in(1i)' => '1987',
                                             'moved_in(2i)' => '01',
                                             'moved_in(3i)' => '01' } } }
      end

      it 'does not change params' do
        post :create, params: person_params
        expect(JSON.parse(response.body)).to eql(expected_response)
      end
    end

    context 'with invalid nested attribute date parts' do
      let(:person_params) do
        {
          person: {
            'name' => 'Joe Bloggs',
            'date_of_birth(1i)' => '1987',
            'date_of_birth(2i)' => '01',
            'date_of_birth(3i)' => '01',
            'address_attributes' => {
              '0' => {
                'address1' => 'wherever',
                'moved_in(1i)' => '1987',
                'moved_in(2i)' => 'JAN',
                'moved_in(3i)' => '32',
                'previous_address' => {
                  '0' => {
                    'prevaddress1' => 'whichever',
                    'moved_out(1i)' => '1977',
                    'moved_out(2i)' => '13',
                    'moved_out(3i)' => 'fifteenth'
                  }
                }
              }
            }
          }
        }
      end

      let(:expected_response) do
        {
          'name' => 'Joe Bloggs',
          'date_of_birth(1i)' => '1987',
          'date_of_birth(2i)' => '01',
          'date_of_birth(3i)' => '01',
          'address_attributes' => {
            '0' => {
              'address1' => 'wherever',
              'moved_in(1i)' => '1987',
              'moved_in(2i)' => '',
              'moved_in(3i)' => '',
              'previous_address' => {
                '0' => {
                  'prevaddress1' => 'whichever',
                  'moved_out(1i)' => '1977',
                  'moved_out(2i)' => '',
                  'moved_out(3i)' => ''
                }
              }
            }
          }
        }
      end

      it 'clears deeply nested invalid day and month values' do
        post :create, params: person_params
        expect(JSON.parse(response.body)).to eql(expected_response)
      end
    end
  end
end
