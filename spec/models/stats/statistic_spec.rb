# == Schema Information
#
# Table name: statistics
#
#  id          :integer          not null, primary key
#  date        :date
#  report_name :string
#  claim_type  :string
#  value_1     :integer
#  value_2     :integer          default(0)
#

require 'rails_helper'

module Stats
  describe Statistic do


    context 'uniqueness' do
      it 'does not allow two records for same date, report type and claim type to be created' do
        create :statistic
        expect {
          create :statistic
        }.to raise_error ActiveRecord::RecordNotUnique, /duplicate key value violates unique constraint "index_statistics_on_date_and_report_name_and_claim_type"/
      end
    end

    describe 'create_or_update' do
      context 'when no record with that key exists' do
        context 'with no value specified for value 2' do
          it 'creates a new record when no record exists' do
            expect(Statistic.count).to eq 0
            Statistic.create_or_update(Date.today, 'my_report', Claim::AdvocateClaim, 566)
            record = Statistic.first
            expect(record.date).to eq Date.today
            expect(record.report_name).to eq 'my_report'
            expect(record.claim_type).to eq 'Claim::AdvocateClaim'
            expect(record.value_1).to eq 566
            expect(record.value_2).to eq 0
          end

          it 'returns 1 if a record has been added' do
            retval = Statistic.create_or_update(Date.today, 'my_report', Claim::AdvocateClaim, 566)
            expect(retval).to eq 1
          end
        end

        context 'with a value specified for value 2' do
          it 'creates a new record when no record exists' do
            expect(Statistic.count).to eq 0
            Statistic.create_or_update(Date.today, 'my_report', Claim::AdvocateClaim, 566, 36)
            record = Statistic.first
            expect(record.date).to eq Date.today
            expect(record.report_name).to eq 'my_report'
            expect(record.claim_type).to eq 'Claim::AdvocateClaim'
            expect(record.value_1).to eq 566
            expect(record.value_2).to eq 36
          end

        end
      end

      context 'record with that key already exists' do
        before(:each)   { Statistic.create_or_update(Date.today, 'my_report', Claim::AdvocateClaim, 566) }

        context 'with no value specified for value 2' do
          it 'updates the existing recofrd with the new value' do
            expect(Statistic.count).to eq 1
            Statistic.create_or_update(Date.today, 'my_report', Claim::AdvocateClaim, 955)
            record = Statistic.first
            expect(record.date).to eq Date.today
            expect(record.report_name).to eq 'my_report'
            expect(record.claim_type).to eq 'Claim::AdvocateClaim'
            expect(record.value_1).to eq 955
          end

          it 'returns 0 if an existing record has been updated' do
            retval = Statistic.create_or_update(Date.today, 'my_report', Claim::AdvocateClaim, 955)
            expect(retval).to eq 0
          end
        end

        context 'with a value specified for value 2' do
          it 'updates the existing recofrd with the new value' do
            expect(Statistic.count).to eq 1
            Statistic.create_or_update(Date.today, 'my_report', Claim::AdvocateClaim, 955, 27)
            record = Statistic.first
            expect(record.date).to eq Date.today
            expect(record.report_name).to eq 'my_report'
            expect(record.claim_type).to eq 'Claim::AdvocateClaim'
            expect(record.value_1).to eq 955
            expect(record.value_2).to eq 27
          end
        end

      end
    end
  end
end
