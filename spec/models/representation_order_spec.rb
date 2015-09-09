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


  context 'non_draft claim validations' do
    let(:claim)                       { FactoryGirl.build :unpersisted_claim }
    let(:representation_order)        { FactoryGirl.build :representation_order }

    before(:each) do
      allow(claim).to receive(:state).and_return('allocated')
      allow(representation_order).to receive(:claim).and_return(claim)
    end

    it 'should validate court type' do
      { "Crown Court" => true, "Magistrates' Court" => true, "Other Court" => false}.each do |court_type, expected_result|
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
      { "Crown Court" => true, "Magistrates' Court" => true, "Other Court" => false}.each do |court_type, expected_result|
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

  context 'reporders for dame defendant methods' do

    let(:claim)         { FactoryGirl.create :claim }
    let(:ro1)            { claim.defendants.first.representation_orders.first }
    let(:ro2)            { claim.defendants.first.representation_orders.last }


    describe '#reporders_for_same_defendant' do
      it 'should return an array of representation orders' do
        rep_orders = ro1.reporders_for_same_defendant
        expect(rep_orders.size).to eq 2
        expect(rep_orders.map(&:class).uniq).to eq( [ RepresentationOrder ] )
        expect(rep_orders.map(&:defendant_id).uniq).to eq( [ claim.defendants.first.id ] )
      end
    end

    describe '#first_reporder_for_same_defendant' do
      it 'should return the first reporder for the same defendant' do
        expect(ro1.first_reporder_for_same_defendant).to eq ro1
      end
    end

    describe 'is_first_reporder_for_same_defendant?' do
      it 'should be true for the first reporder' do
        expect(ro1.is_first_reporder_for_same_defendant?).to be true
      end

      it 'should be false for other reporders' do
        expect(ro2.is_first_reporder_for_same_defendant?).to be false
      end

    end
  end



end
