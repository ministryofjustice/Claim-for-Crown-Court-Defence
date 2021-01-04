require 'rails_helper'
require File.join(Rails.root, 'lib', 'working_day_calculator')

describe WorkingDayCalculator do
  let(:tue_19_jul) { Date.new(2016, 7, 19) }
  let(:mon_18_jul) { Date.new(2016, 7, 18) }
  let(:sun_17_jul) { Date.new(2016, 7, 17) }
  let(:sat_16_jul) { Date.new(2016, 7, 16) }
  let(:thu_14_jul) { Date.new(2016, 7, 14) }
  let(:fri_15_jul) { Date.new(2016, 7, 15) }
  let(:mon_11_jul) { Date.new(2016, 7, 11) }
  let(:sun_10_jul) { Date.new(2016, 7, 10) }
  let(:sat_9_jul)  { Date.new(2016, 7, 9) }
  let(:mon_4_jul)  { Date.new(2016, 7, 4) }
  let(:sun_3_jul)  { Date.new(2016, 7, 3) }
  let(:thu_30_jun) { Date.new(2016, 6, 30) }

  describe '#working days' do
    context 'over one weekend' do
      it 'should return the exepected number of days over one weekend' do
        expectations = [
          [thu_14_jul, mon_18_jul, 2],
          [sat_16_jul, mon_18_jul, 0],
          [sat_16_jul, sun_17_jul, 0]
        ]
        expectations.each { |ex| expect_working_days(ex) }
      end
    end

    context 'within one week' do
      it 'should return the exepected number of days within one week' do
        expectations = [
          [mon_11_jul, mon_11_jul, 0],
          [mon_11_jul, fri_15_jul, 4]
        ]
        expectations.each { |ex| expect_working_days(ex) }
      end
    end

    context 'weekend to weekend' do
      it 'should return the expected number of days when submitted one weekend and decided the next' do
        expectations = [
          [sat_9_jul, sun_17_jul, 4],
          [sun_10_jul, sat_16_jul, 4],
          [sun_3_jul, mon_18_jul, 10]
        ]
        expectations.each { |ex| expect_working_days(ex) }
      end
    end

    context 'spanning two weekends' do
      it 'should return the expected number of days when period spans two full weekends' do
        expectations = [
          [thu_30_jun, tue_19_jul, 13]
        ]
        expectations.each { |ex| expect_working_days(ex) }
      end
    end
  end

  def expect_working_days(expectation)
    start_day, end_day, num_days = expectation
    expect(WorkingDayCalculator.new(start_day, end_day).working_days).to eq num_days
  end
end
