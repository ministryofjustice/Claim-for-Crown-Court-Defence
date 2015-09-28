require 'rails_helper'

RSpec.describe ClaimPresenter do

  let(:claim) { create :claim }
  subject { ClaimPresenter.new(claim, view) }

  before do
    Timecop.freeze(Time.current)
    @first_defendant = claim.defendants.first
    create(:defendant, first_name: 'John', middle_name: 'Robert', last_name: 'Smith', claim: claim, order_for_judicial_apportionment: false)
    create(:defendant, first_name: 'Adam', middle_name: '', last_name: 'Smith', claim: claim, order_for_judicial_apportionment: false)
  end

  after { Timecop.return }

  it '#defendant_names' do
    expect(subject.defendant_names).to eql("#{@first_defendant.name},<br />John Robert Smith,<br />Adam Smith")
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
    expect{subject.paid_at(rubbish: false) }.to raise_error(ArgumentError)
  end


  describe '#assessment_date' do
    it 'should return not yet assessed if there is no assessment' do
      expect(subject.assessment_date).to eq '(not yet assessed)'
    end

    it 'should return the creation date of the assessment' do
      Timecop.freeze Time.new(2015, 8, 13, 14, 55, 23) do
        assessment = FactoryGirl.create :assessment, claim: claim
        expect(subject.assessment_date).to eq '13/08/2015'
      end
    end
  end

  describe 'assessment_fees' do
    it 'should return formatted assessment fees' do
      assessment = FactoryGirl.create :assessment, claim: claim, fees: 1234.56
      expect(subject.assessment_fees).to eq '£1,234.56'
    end
  end

  describe 'assessment_expenses' do
    it 'should return formatted assessment expense' do
      assessment = FactoryGirl.create :assessment, claim: claim, expenses: 1234.56
      expect(subject.assessment_expenses).to eq '£1,234.56'
    end
  end

  describe '#retrial' do

    it 'returns yes for case types like retrial' do
      claim.case_type = CaseType.find_or_create_by!(name: 'Retrial')
      expect(subject.retrial).to eql 'Yes'
    end

    it 'returns no for case types NOT like retrial' do
      claim.case_type = CaseType.find_or_create_by!(name: 'Contempt')
      expect(subject.retrial).to eql 'No'
    end

  end

  describe '#any_judicial_apportionments' do

    it "returns yes if any defendants have an order for judicial apportionment" do
      @first_defendant.update_attribute(:order_for_judicial_apportionment,true)
      expect(subject.any_judicial_apportionments).to eql 'Yes'
    end

    it "returns no if no defendants have an order for judicial apportionment" do
      @first_defendant.update_attribute(:order_for_judicial_apportionment,false)
      expect(subject.any_judicial_apportionments).to eql 'No'
    end

  end

  # TODO: do currency converters need internationalisation??
  it '#amount_assessed' do
    claim.assessment.update(fees: 80.35, expenses: 19.65)
    expect(subject.assessment_total).to eql("£100.00")
  end

  it '#fees_total' do
    claim.fees_total = 100
    expect(subject.fees_total).to eql("£100.00")
  end

  it '#expenses_total' do
    claim.expenses_total = 100
    expect(subject.expenses_total).to eql("£100.00")
  end

  it "#total_inc_vat" do
    claim.total = 60
    claim.vat_amount = 40
    expect(subject.total_inc_vat).to eql("£100.00")
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

  describe '#representation_order_details' do

    claim = FactoryGirl.build :unpersisted_claim
    subject { ClaimPresenter.new(claim, view) }

    it 'should return an html safe string of all the dates and granting bodies' do

      defendant_1 = FactoryGirl.build :defendant
      defendant_2 = FactoryGirl.build :defendant
      Timecop.freeze 5.days.ago do
        defendant_1.representation_orders = [
          FactoryGirl.build(:representation_order, representation_order_date: Date.new(2015,3,1), granting_body: "Crown Court", maat_reference: '1234abc'),
          FactoryGirl.build(:representation_order, representation_order_date: Date.new(2015,8,13), granting_body: "Magistrates' Court", maat_reference: 'abc1234'),
        ]
      end
      Timecop.freeze 2.days.ago do
        defendant_2.representation_orders =[ FactoryGirl.build(:representation_order, representation_order_date: Date.new(2015,3,1), granting_body: "Magistrates' Court", maat_reference: 'xyz4321') ]
      end
      claim.defendants = [ defendant_1, defendant_2 ]
      expect(subject.representation_order_details).to eq( "Crown Court 01/03/2015 1234abc<br />Magistrates&#39; Court 13/08/2015 abc1234<br />Magistrates&#39; Court 01/03/2015 xyz4321" )
    end
  end

  it '#case_worker_names' do
    claim.case_workers << FactoryGirl.build(:case_worker, user: FactoryGirl.build(:user, first_name: "Alexander", last_name: 'Bell'))
    claim.case_workers << FactoryGirl.build(:case_worker, user: FactoryGirl.build(:user, first_name: "Louis", last_name: 'Pasteur'))
    expect(subject.case_worker_names).to eq('Alexander Bell, Louis Pasteur')
  end
end
