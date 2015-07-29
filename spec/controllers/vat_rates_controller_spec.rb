require 'rails_helper'

RSpec.describe VatRatesController, type: :controller do


  before(:all) do
    FactoryGirl.create :vat_rate, effective_date: Date.new(2000, 1, 1),  rate_base_points: 1750
    FactoryGirl.create :vat_rate, effective_date: Date.new(2011, 4, 1),  rate_base_points: 2000
    # reload rates into the class variable to prevent stale rates from previous tests being used.
    VatRate.load_rates
  end

  after(:all) do
    VatRate.delete_all
  end


  describe 'GET vat' do

    it 'should return JSON struct with details' do
      get :index, {:format => 'json', 'net_amount' => '115.76', 'date' => '2015-07-15' }
      expect(response).to have_http_status(200)
      expect(response.body).to eq(
        {
          'net_amount'    => '115.76',
          'date'          => '2015-07-15',
          'rate'          => '20%',
          'vat_amount'    => '23.15'
        }.to_json
      )
    end

    it 'should round the net_amount to two decimal places' do
      get :index, {:format => 'json', 'net_amount' => '115.768744', 'date' => '2006-07-15' }
      expect(response).to have_http_status(200)
      expect(response.body).to eq(
        {
          'net_amount'    => '115.77',
          'date'          => '2006-07-15',
          'rate'          => '17.5%',
          'vat_amount'    => '20.26'
        }.to_json
      )
    end

  end

end

