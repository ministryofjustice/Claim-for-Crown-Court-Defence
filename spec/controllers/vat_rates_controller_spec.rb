# == Schema Information
#
# Table name: vat_rates
#
#  id               :integer          not null, primary key
#  rate_base_points :integer
#  effective_date   :date
#  created_at       :datetime
#  updated_at       :datetime
#

require 'rails_helper'

RSpec.describe VatRatesController, type: :controller do
  before do
    VatRate.delete_all
    create(:vat_rate, effective_date: Date.new(2000, 1, 1), rate_base_points: 1750)
    create(:vat_rate, effective_date: Date.new(2011, 4, 1), rate_base_points: 2000)
  end

  describe 'GET vat' do
    context 'advocate claims' do
      it 'if vat applies, it should return JSON struct with details' do
        get :index, params: { :format => 'json', 'apply_vat' => 'true', 'net_amount' => '115.76', 'date' => '2015-07-15', 'scheme' => 'agfs' }
        expect(response).to be_successful
        expect(response.body).to eq(
          {
            'net_amount' => '£115.76',
            'date' => '15/07/2015',
            'rate' => '20%',
            'vat_amount' => '£23.15',
            'total_inc_vat' => '£138.91'
          }.to_json
        )
      end

      it 'if vat applies, it should round the net_amount to two decimal places' do
        get :index, params: { :format => 'json', 'apply_vat' => 'true', 'net_amount' => '3115.768744', 'date' => '2006-07-15', 'scheme' => 'agfs' }
        expect(response).to be_successful
        expect(response.body).to eq(
          {
            'net_amount' => '£3,115.77',
            'date' => '15/07/2006',
            'rate' => '17.5%',
            'vat_amount' => '£545.26',
            'total_inc_vat' => '£3,661.03'
          }.to_json
        )
      end

      it 'if vat does not apply, it should return JSON struct with details and total_inc_vat = net_amount' do
        get :index, params: { :format => 'json',  'apply_vat' => 'false', 'net_amount' => '115.76', 'date' => '2015-07-15', 'scheme' => 'agfs' }
        expect(response).to be_successful
        expect(response.body).to eq(
          {
            'net_amount' => '£115.76',
            'date' => '',
            'rate' => '0%',
            'vat_amount' => '£0.00',
            'total_inc_vat' => '£115.76'
          }.to_json
        )
      end

      it 'if vat does not apply, it should round the net_amount to two decimal places and total_inc_vat = net_amount' do
        get :index, params: { :format => 'json', 'apply_vat' => 'false', 'net_amount' => '3115.768744', 'date' => '2006-07-15', 'scheme' => 'agfs' }
        expect(response).to be_successful
        expect(response.body).to eq(
          {
            'net_amount' => '£3,115.77',
            'date' => '',
            'rate' => '0%',
            'vat_amount' => '£0.00',
            'total_inc_vat' => '£3,115.77'
          }.to_json
        )
      end
    end

    context 'litigator claims' do
      it 'should add a flat vat amount provided by user and round to two decimal places ' do
        get :index, params: { :format => 'json', 'net_amount' => '3115.768744', 'date' => '2006-07-15', 'scheme' => 'lgfs', 'lgfs_vat_amount' => '22.229' }
        expect(response).to be_successful
        expect(response.body).to eq(
          {
            'net_amount' => '£3,115.77',
            'date' => '',
            'rate' => '0%',
            'vat_amount' => '£22.23',
            'total_inc_vat' => '£3,138.00'
          }.to_json
        )
      end
    end
  end
end
