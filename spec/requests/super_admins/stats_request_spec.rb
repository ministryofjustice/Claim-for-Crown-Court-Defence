require 'rails_helper'

def post_with_params(from, to)
  from = from.split('/')
  to = to.split('/')

  post '/super_admins/stats', params: { 'date_from(3i)': from[0], 'date_from(2i)': from[1], 'date_from(1i)': from[2],
                                        'date_to(3i)': to[0], 'date_to(2i)': to[1], 'date_to(1i)': to[2] }
end

RSpec.describe 'Stats' do
  context 'when logged in as a case worker' do
    before do
      case_worker = create(:case_worker)
      sign_in(case_worker.user)
    end

    it 'redirects the user' do
      get '/super_admins/stats'

      expect(response).to redirect_to case_workers_root_path
    end
  end

  context 'when logged in as an external user' do
    before do
      external_user = create(:external_user)
      sign_in(external_user.user)
    end

    it 'redirects the user' do
      get '/super_admins/stats'

      expect(response).to redirect_to external_users_root_path
    end
  end

  context 'when not logged in' do
    it 'redirects the user' do
      get '/super_admins/stats'

      expect(response).to redirect_to new_user_session_path
    end
  end

  context 'when logged in as super_admin' do
    before do
      super_admin = create(:super_admin)
      sign_in(super_admin.user)
    end

    describe 'GET stats' do
      before do
        create(:advocate_final_claim, :submitted)
        create(:litigator_final_claim, :submitted)
        create(:litigator_final_claim, :submitted)
        create(:litigator_final_claim, :submitted)

        get '/super_admins/stats'
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'renders the template' do
        expect(response).to render_template(:show)
      end

      it 'includes the correct date when provided with valid date parameters' do
        expect(response.body).to include(
          "#{Time.zone.now.at_beginning_of_month.strftime('%d %b')} - #{Time.zone.now.strftime('%d %b')}"
        )
      end

      it 'includes the correct claims data in the pie chart with GET' do
        expect(response.body).to match(/(total-claims-chart).*1.*3.*(legend)/)
      end

      it 'includes the correct claims data in the line chart with GET' do
        expect(response.body).to match(/(total-claim-values-chart).*25.0.*75.0.*(colors)/)
      end

      it 'has more potential colours than Fee Schemes' do
        # This will only fail if more fee schemes are added than colours in the palette, to prevent re-use. As written,
        # there are some extra colours added to account for changes in the future. If this fails, add more colour hex
        # codes to @chart_colours

        expect(assigns(:chart_colours).count).to be > assigns(:six_month_breakdown).count
      end

      describe 'six month breakdown' do
        before do
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

          travel_to Time.zone.local(2023, 6, 30) do
            get '/super_admins/stats'
          end
        end

        it 'generates correct AGFS data for a six month graph' do
          expect(response.body).to match(
            /"name":"AGFS \d+","data":\[\["Jan",2\],\["Feb",1\],\["Mar",2\],\["Apr",1\],\["May",2\],\["Jun",1\]\]/
          )
        end

        it 'generates correct LGFS 9 data for a six month graph' do
          expect(response.body).to match(
            /"name":"LGFS \d+","data":\[\["Jan",1\],\["Feb",2\],\["Mar",1\],\["Apr",2\],\["May",1\],\["Jun",2\]\]/
          )
        end
      end
    end

    describe 'POST stats' do
      let(:date) { Time.zone.today - 1.year }

      describe 'valid parameters' do
        before do
          travel_to Time.zone.local(date.year, 6, 10) do
            create(:advocate_final_claim, :submitted)
            create(:litigator_final_claim, :submitted)
            create(:litigator_final_claim, :submitted)
          end
          post_with_params("1/6/#{date.year}", "30/6/#{date.year}")
        end

        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end

        it 'renders the template' do
          expect(response).to render_template(:show)
        end

        it 'includes the correct date when provided with valid date parameters' do
          expect(response.body).to include('01 Jun - 30 Jun')
        end

        it 'includes the correct claims data in the pie chart when provided with valid POST params' do
          expect(response.body).to match(/(total-claims-chart).*,1.*,2.*(legend)/)
        end

        it 'includes the correct claims data in the line chart when provided with valid POST parameters' do
          expect(response.body).to match(/(total-claim-values-chart).*25.0.*50.0.*(colors)/)
        end
      end

      describe 'invalid parameters' do
        it 'provides default dates when provided with blank POST parameters' do
          post_with_params('//', '//')

          expect(response.body).to include(
            "#{Time.zone.now.at_beginning_of_month.strftime('%d %b')} - #{Time.zone.now.strftime('%d %b')}"
          )
        end

        it 'provides default dates when provided with invalid POST parameters' do
          post_with_params('01/02/2023', '01/01/2023')

          expect(response.body).to include(
            "#{Time.zone.now.at_beginning_of_month.strftime('%d %b')} - #{Time.zone.now.strftime('%d %b')}"
          )
        end

        it 'displays an error when provided with invalid POST parameters' do
          post_with_params('01/02/2023', '01/01/2023')

          expect(response.body).to include('Please enter a valid set of dates')
        end
      end
    end
  end
end
