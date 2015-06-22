require 'rails_helper'

RSpec.describe FeePresenter do

  before { Timecop.freeze(Time.current) }
  after { Timecop.return }

  let(:frozen_time)   { Time.current }
  let(:claim)         { create(:claim) }
  let(:fee_type)      { create(:fee_type, description: 'Basic fee type C') }
  let(:fee)           { create(:fee, quantity: 4, rate: 5.40, claim: claim, fee_type: fee_type) }

  it '#dates_attended_delimited_string' do
    create(:date_attended, fee: fee , date: frozen_time)
    create(:date_attended, fee: fee , date: frozen_time + 1.day)
    claim.fees.each do |fee|
      fee = FeePresenter.new(fee, view)
      dt = frozen_time.strftime('%d/%m/%Y') + ', ' + (frozen_time + 1.day).strftime('%d/%m/%Y')
      expect(fee.dates_attended_delimited_string).to eql(dt)
    end
  end

  it '#amount' do
    create(:fee, quantity: 4, rate: 5.40, claim: claim, fee_type: fee_type)
    claim.fees.each do |fee|
      fee = FeePresenter.new(fee, view)
      expect(fee.amount).to eql("£21.60")
    end
  end

end
