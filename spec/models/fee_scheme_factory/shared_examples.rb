require 'rails_helper'

RSpec.shared_examples 'execute without error' do
  it { expect { Timeout.timeout(1) { subject } }.not_to raise_error }
end

RSpec.shared_examples 'a fee scheme factory' do
  context 'with a representation order date of class type Date' do
    let(:options) { { representation_order_date: Time.zone.now.to_date } }

    include_examples 'execute without error'
  end

  context 'with a representation order date of class type DateTime' do
    let(:options) { { representation_order_date: DateTime.now } }

    include_examples 'execute without error'
  end

  context 'with a representation order date of class type ActiveSupport::TimeWithZone' do
    let(:options) { { representation_order_date: Time.zone.now } }

    include_examples 'execute without error'
  end

  context 'with a main hearing date of class type Date' do
    let(:options) { { representation_order_date: 1.month.ago, main_hearing_date: Time.zone.now.to_date } }

    include_examples 'execute without error'
  end

  context 'with a main hearing date of class type DateTime' do
    let(:options) { { representation_order_date: 1.month.ago, main_hearing_date: DateTime.now } }

    include_examples 'execute without error'
  end

  context 'with a main hearing date of class type ActiveSupport::TimeWithZone' do
    let(:options) { { representation_order_date: 1.month.ago, main_hearing_date: Time.zone.now } }

    include_examples 'execute without error'
  end
end
