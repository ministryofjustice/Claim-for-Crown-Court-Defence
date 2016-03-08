require 'rails_helper'

module Claim
  describe BaseClaim do

    let(:advocate)   { create :external_user, :advocate }
    let(:agfs_claim) { create(:advocate_claim) }
    let(:lgfs_claim) { create(:litigator_claim) }

    it 'raises if I try to instantiate a base claim' do
      expect {
        claim = BaseClaim.new(external_user: advocate, creator: advocate)
      }.to raise_error ::Claim::BaseClaimAbstractClassError, 'Claim::BaseClaim is an abstract class and cannot be instantiated'
    end

    describe '#owner' do
      it 'returns creator for lgfs claims' do
        expect(lgfs_claim.owner).to eql lgfs_claim.creator
      end
      it 'returns external_user for agfs claims' do
        expect(agfs_claim.owner).to eql agfs_claim.external_user
      end
    end

    describe '#agfs?' do
      it 'returns true if claim is advocate/agfs claim, false for litigator/lgfs claims' do
        expect(agfs_claim.agfs?).to eql true
        expect(lgfs_claim.agfs?).to eql false
      end
    end

    describe '#lgfs?' do
      it 'returns true if claim is litigator/lgfs claim, false for advocate/agfs claims' do
        expect(lgfs_claim.lgfs?).to eql true
        expect(agfs_claim.lgfs?).to eql false
      end
    end

  end

  class MockBaseClaim < BaseClaim; end

  describe MockBaseClaim do
    context 'date formatting' do
      it 'should accept a variety of formats and populate the date accordingly' do
        def make_date_params(date_string)
          day, month, year = date_string.split('-')
           {
             "first_day_of_trial_dd" => day,
             "first_day_of_trial_mm" => month,
             "first_day_of_trial_yyyy" => year,
           }
        end

        dates = {
         '04-10-80'    => Date.new(80, 10, 04),
         '04-10-1980'  => Date.new(1980, 10, 04),
         '04-1-1980'   => Date.new(1980, 01, 04),
         '4-1-1980'    => Date.new(1980, 01, 04),
         '4-10-1980'   => Date.new(1980, 10, 04),
         '4-Oct-1980'  => Date.new(1980, 10, 04),
         '04-Oct-1980' => Date.new(1980, 10, 04),
         '04-10-10'    => Date.new(10, 10, 04),
         '04-10-2010'  => Date.new(2010, 10, 04),
         '04-1-2010'   => Date.new(2010, 01, 04),
         '4-1-2010'    => Date.new(2010, 01, 04),
         '4-10-2010'   => Date.new(2010, 10, 04),
         '4-Oct-2010'  => Date.new(2010, 10, 04),
         '04-Oct-2010' => Date.new(2010, 10, 04),
         '04-nov-2001' => Date.new(2001, 11, 04),
         '4-jAn-1999'  => Date.new(1999, 01, 04),
        }
        dates.each do |date_string, date|
          params = make_date_params(date_string)
          claim = MockBaseClaim.new(params)
          expect(claim.first_day_of_trial).to eq date
        end
      end
    end
  end

end

