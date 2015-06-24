require 'rails_helper'

RSpec.describe ClaimPresenter do

  let(:claim) { create :claim }
  subject { ClaimPresenter.new(claim, view) }

  before do
    Timecop.freeze(Time.current)
    create(:defendant, first_name: 'John', last_name: 'Smith', claim: claim)
    create(:defendant, first_name: 'Adam', last_name: 'Smith', claim: claim)
  end

  after { Timecop.return }

  it '#defendant_names' do
    expect(subject.defendant_names).to eql('John Smith, Adam Smith')
  end

  it '#submitted_at' do
    claim.submitted_at = Time.current
    expect(subject.submitted_at).to eql(Time.current.strftime('%d/%m/%Y'))
    expect(subject.submitted_at(include_time: true)).to eql(Time.current.strftime('%d/%m/%Y %H:%M'))
  end

  it '#paid_at' do
    claim.paid_at = Time.current
    expect(subject.paid_at).to eql(Time.current.strftime('%d/%m/%Y'))
    expect(subject.paid_at(include_time: false)).to eql(Time.current.strftime('%d/%m/%Y'))
    expect(subject.paid_at(include_time: true)).to eql(Time.current.strftime('%d/%m/%Y %H:%M'))
    expect{ subject.paid_at(rubbish: false) }.to raise_error(ArgumentError)
  end

  # TODO: do currency converters need internationalisation??
  it '#amount_assessed' do
    claim.amount_assessed = 100
    expect(subject.amount_assessed).to eql("£100.00")
  end

  it '#fees_total' do
    claim.fees_total = 100
    expect(subject.fees_total).to eql("£100.00")
  end

  it '#expenses_total' do
    claim.expenses_total = 100
    expect(subject.expenses_total).to eql("£100.00")
  end

  it '#status_image' do
    c = claim
    c.submit!; c.allocate!; c.await_info_from_court!
    expect(subject.status_image).to eq('awaiting-info-from-court.png')
  end

  it '#status_image_tag' do
    c = claim
    c.submit!; c.allocate!; c.await_info_from_court!
    expect(subject.status_image_tag).to include("alt=\"Awaiting info from court\"")
  end

  it '#case_worker_email_addresses' do
    cw1 = build(:case_worker)
    cw2 = build(:case_worker)
    cw1.user.email = 'john@bigblackhole.com'
    cw2.user.email = 'bob@bigblackhole.com'
    claim.case_workers << cw1
    claim.case_workers << cw2
    expect(subject.case_worker_email_addresses).to eql('john@bigblackhole.com, bob@bigblackhole.com')
  end

  it '#caseworker_claim_id' do
    expect(subject.caseworker_claim_id).to eql("claim_ids_#{claim.id}")
  end

end