require 'rails_helper'

def sign_in_sa
  super_admin = create(:super_admin)

  sign_in(super_admin.user)
end

RSpec.describe SuperAdmins::StatsController do
  context 'when not logged in as Super Admin' do
    it 'redirects the user' do
      get :show
      expect(response).to have_http_status(:found)
    end
  end

  context 'when logged in as Super Admin' do
    before do
      sign_in_sa
      get :show
    end

    it 'uses the show template' do
      expect(response).to render_template(:show)
    end

    it 'returns a 200' do
      expect(response).to have_http_status(:ok)
    end
  end

  context 'when processing dates' do
    before { sign_in_sa }

    it 'provides default dates when not provided prams' do
      get :show
      expect([assigns(:from_str), assigns(:to_str)]).to eq([Time.zone.now.at_beginning_of_month.strftime('%d %b'),
                                                            Time.zone.now.strftime('%d %b')])
    end

    it 'provides default dates when not provided empty params' do
      get :show, params: { 'date_from(3i)': '', 'date_from(2i)': '', 'date_from(1i)': '',
                           'date_to(3i)': '', 'date_to(2i)': '', 'date_to(1i)': '' }
      expect([assigns(:from_str), assigns(:to_str)]).to eq([Time.zone.now.at_beginning_of_month.strftime('%d %b'),
                                                            Time.zone.now.strftime('%d %b')])
    end

    it 'processes dates when provided params' do
      get :show, params: { 'date_from(3i)': '01', 'date_from(2i)': '08', 'date_from(1i)': '2023',
                           'date_to(3i)': '31', 'date_to(2i)': '08', 'date_to(1i)': '2023' }
      expect([assigns(:from_str), assigns(:to_str)]).to eq(['01 Aug', '31 Aug'])
    end

    it 'provides default dates when given invalid params' do
      get :show, params: { 'date_from(3i)': '01', 'date_from(2i)': '02', 'date_from(1i)': '2023',
                           'date_to(3i)': '01', 'date_to(2i)': '01', 'date_to(1i)': '2023' }
      expect([assigns(:from_str), assigns(:to_str)]).to eq([Time.zone.now.at_beginning_of_month.strftime('%d %b'),
                                                            Time.zone.now.strftime('%d %b')])
    end

    it 'displays an error when given invalid params' do
      get :show, params: { 'date_from(3i)': '01', 'date_from(2i)': '02', 'date_from(1i)': '2023',
                           'date_to(3i)': '01', 'date_to(2i)': '01', 'date_to(1i)': '2023' }
      expect(assigns(:date_err)).to be(true)
    end
  end

  context 'when generating stats for pie and column charts' do
    before do
      sign_in_sa
      create(:advocate_final_claim, :submitted)
      create(:advocate_final_claim, :submitted)
      create(:litigator_final_claim, :submitted)

      travel_to Time.zone.local(2023, 6, 3) do
        create(:advocate_final_claim, :submitted)
        create(:litigator_final_claim, :submitted)
        create(:litigator_final_claim, :submitted)
      end
    end

    it 'has more potential colours than Fee Schemes' do
      # This will only fail if more fee schemes are added than colours in the palette, to prevent re-use. As written,
      # there are some extra colours added to account for changes in the future. If this fails, add more colour hex
      # codes to @chart_colours
      get :show

      expect(assigns(:chart_colours).count).to be > assigns(:ordered_fee_schemes).count
    end

    context 'when using the default dates' do
      before { get :show }

      it 'generates correct data for the pie chart' do
        expect(assigns(:total_claims).to_s).to match(/=>2.*=>1/)
      end

      it 'generates correct data for the values column chart' do
        expect(assigns(:total_values).to_s).to match(/=>50.*=>25/)
      end
    end

    context 'when using user entered dates' do
      before do
        get :show, params: { 'date_from(3i)': '01', 'date_from(2i)': '06', 'date_from(1i)': '2023',
                             'date_to(3i)': '30', 'date_to(2i)': '06', 'date_to(1i)': '2023' }
      end

      it 'generates correct data for the pie chart' do
        expect(assigns(:total_claims).to_s).to match(/=>1.*=>2/)
      end

      it 'generates correct data for the values column chart' do
        expect(assigns(:total_values).to_s).to match(/=>25.*=>50/)
      end
    end
  end

  context 'when generating stats for previous six months' do
    let(:agfs_nine_hash) { { name: 'AGFS 9', data: { Jan: 1, Feb: 1, Mar: 1, Apr: 1, May: 1, Jun: 1 } } }
    let(:lgfs_nine_hash) { { name: 'AGFS 9', data: { Jan: 1, Feb: 1, Mar: 1, Apr: 1, May: 1, Jun: 1 } } }

    before do
      sign_in_sa

      travel_to Time.zone.local(2023, 1, 1) do
        create(:advocate_final_claim, :submitted)
        create(:advocate_final_claim, :submitted)
        create(:litigator_final_claim, :submitted)
      end
      travel_to Time.zone.local(2023, 2, 1) do
        create(:advocate_final_claim, :submitted)
        create(:litigator_final_claim, :submitted)
        create(:litigator_final_claim, :submitted)
      end
      travel_to Time.zone.local(2023, 3, 1) do
        create(:advocate_final_claim, :submitted)
        create(:advocate_final_claim, :submitted)
        create(:litigator_final_claim, :submitted)
      end
      travel_to Time.zone.local(2023, 4, 1) do
        create(:advocate_final_claim, :submitted)
        create(:litigator_final_claim, :submitted)
        create(:litigator_final_claim, :submitted)
      end
      travel_to Time.zone.local(2023, 5, 1) do
        create(:advocate_final_claim, :submitted)
        create(:advocate_final_claim, :submitted)
        create(:litigator_final_claim, :submitted)
      end
      travel_to Time.zone.local(2023, 6, 1) do
        create(:advocate_final_claim, :submitted)
        create(:litigator_final_claim, :submitted)
        create(:litigator_final_claim, :submitted)
      end
    end

    it 'generates correct AGFS 9 data for a six month graph' do
      travel_to Time.zone.local(2023, 6, 30) do
        get :show
      end

      expect(assigns(:six_month_breakdown).to_s).to match(/"Jan"=>2, "Feb"=>1, "Mar"=>2, "Apr"=>1, "May"=>2, "Jun"=>1/)
    end

    it 'generates correct LGFS 9 data for a six month graph' do
      travel_to Time.zone.local(2023, 6, 30) do
        get :show
      end

      expect(assigns(:six_month_breakdown).to_s).to match(/"Jan"=>1, "Feb"=>2, "Mar"=>1, "Apr"=>2, "May"=>1, "Jun"=>2/)
    end
  end
end
