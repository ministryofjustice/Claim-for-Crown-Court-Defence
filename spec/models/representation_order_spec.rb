# == Schema Information
#
# Table name: representation_orders
#
#  id                        :integer          not null, primary key
#  defendant_id              :integer
#  created_at                :datetime
#  updated_at                :datetime
#  granting_body             :string(255)
#  maat_reference            :string(255)
#  representation_order_date :date
#  uuid                      :uuid
#

require 'rails_helper'

describe RepresentationOrder do

  it { should validate_presence_of(:representation_order_date) }

  # it { should validate_inclusion_of(:granting_body).in_array( ["Magistrate's Court", "Crown Court"] ) }

  context 'non_draft claim validations' do
    let(:claim)                       { FactoryGirl.build :unpersisted_claim }
    let(:representation_order)        { FactoryGirl.build :representation_order }

    before(:each) do
      allow(claim).to receive(:state).and_return('allocated')
      allow(representation_order).to receive(:claim).and_return(claim)
    end

    it 'should validate court type' do
      { "Crown Court" => true, "Magistrate's Court" => true, "Other Court" => false}.each do |court_type, expected_result|
        representation_order.granting_body = court_type
        expect(representation_order.valid?).to eq expected_result
      end
    end
  end


  context 'draft claim validations' do
    let(:claim)                       { FactoryGirl.build :unpersisted_claim }
    let(:representation_order)        { FactoryGirl.build :representation_order }

    before(:each) do
      allow(claim).to receive(:state).and_return('draft')
      allow(representation_order).to receive(:claim).and_return(claim)
    end

    it 'should validate court type' do
      { "Crown Court" => true, "Magistrate's Court" => true, "Other Court" => false}.each do |court_type, expected_result|
        representation_order.granting_body = court_type
        expect(representation_order.valid?).to eq expected_result
      end
    end
  end

  context 'maat_reference' do
    it 'should upcase maat reference on save' do
      ro = FactoryGirl.build :representation_order, maat_reference: 'abcdef34rt'
      ro.save!
      expect(ro.maat_reference).to eq 'ABCDEF34RT'
    end
  end



end
