require 'rails_helper'

describe Claims::Count do
  subject(:claims_count) { described_class.new(date, period) }

  let(:date) { Date.new(2018,1,20) }
  let(:period) { :month }

  before do
    travel_to(Date.new(2017, 12, 17)) { create_list(:archived_pending_delete_claim, 3) }
    travel_to(Date.new(2018, 01, 17)) { create_list(:archived_pending_delete_claim, 3) }
    travel_to(Date.new(2018, 02, 17)) { create_list(:archived_pending_delete_claim, 3) }
  end

  it { expect(subject).to be_a Claims::Count }

  describe '#call' do
    context 'when period and date are set manually' do
      subject(:call) { claims_count.call }

      it { is_expected.to eql 3 }
    end
  end

  context 'class methods' do
    describe '.quarter' do
      subject { described_class.quarter(date) }

      it { is_expected.to eql 6 }
    end

    describe '.month' do
      subject { described_class.month(date) }

      it { is_expected.to eql 3 }
    end

    describe '.week' do
      context 'when the week has data' do
        subject { described_class.week(date) }

        it { is_expected.to eql 3 }
      end

      context 'when the week has no data' do
        subject { described_class.week(date + 7.days) }

        it { is_expected.to eql 0 }
      end
    end
  end
end
