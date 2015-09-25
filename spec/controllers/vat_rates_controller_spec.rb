require 'rails_helper'

RSpec.describe VatRatesController, type: :controller do


  before(:all) do
    @vr1 = FactoryGirl.create :vat_rate, effective_date: Date.new(2000, 1, 1),  rate_base_points: 1750
    @vr2 = FactoryGirl.create :vat_rate, effective_date: Date.new(2011, 4, 1),  rate_base_points: 2000
  end

  after(:all) do
    VatRate.destroy( [ @vr1.id, @vr2.id ] )
  end


  describe 'GET vat' do

    it 'should return JSON struct with details' do
      get :index, {:format => 'json', 'net_amount' => '115.76', 'date' => '2015-07-15' }
      expect(response).to have_http_status(200)
      expect(response.body).to eq(
        {
          'net_amount'    => '£115.76',
          'date'          => '15/07/2015',
          'rate'          => '20%',
          'vat_amount'    => '£23.15'
        }.to_json
      )
    end

    it 'should round the net_amount to two decimal places' do
      get :index, {:format => 'json', 'net_amount' => '3115.768744', 'date' => '2006-07-15' }
      expect(response).to have_http_status(200)
      expect(response.body).to eq(
        {
          'net_amount'    => '£3,115.77',
          'date'          => '15/07/2006',
          'rate'          => '17.5%',
          'vat_amount'    => '£545.26'
        }.to_json
      )
    end

  end

end

