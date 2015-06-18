require 'rails_helper'

RSpec.describe ClaimPresenter do

  let(:claim) { create :claim }
  subject { ClaimPresenter.new(claim, view) }

  before do
    create(:defendant, first_name: 'John', last_name: 'Smith', claim: claim)
    create(:defendant, first_name: 'Adam', last_name: 'Smith', claim: claim)
  end

  it '#defendant_names' do
    expect(subject.defendant_names).to eql('Adam Smith, John Smith')
  end

  it '#submitted_at' do
    claim.submitted_at = Time.current
    expect(subject.submitted_at).to eql(Time.current.strftime('%d/%m/%Y'))
    expect(subject.submitted_at(include_time: true)).to eql(Time.current.strftime('%d/%m/%Y %H:%M'))
  end

  # it { expect(subject.paid_at).to receive()

  it '#paid_at' do
    claim.paid_at = Time.current
    expect(subject.paid_at).to eql(Time.current.strftime('%d/%m/%Y'))
    expect(subject.paid_at(include_time: false)).to eql(Time.current.strftime('%d/%m/%Y'))
    expect(subject.paid_at(include_time: true)).to eql(Time.current.strftime('%d/%m/%Y %H:%M'))
    expect(subject.paid_at(rubbish: false)).to eql(Time.current.strftime('%d/%m/%Y'))
  end


end