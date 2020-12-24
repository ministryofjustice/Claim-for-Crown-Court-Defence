require 'rails_helper'
require 'cgi'

RSpec.shared_examples 'last claim state transition reason_text' do
  let(:mock_claim_state_transitions) do
    [
      instance_double(ClaimStateTransition, reason_text: 'first reason'),
      instance_double(ClaimStateTransition, reason_text: 'another reason'),
      instance_double(ClaimStateTransition, reason_text: 'last reason')
    ]
  end

  before { allow(claim).to receive(:claim_state_transitions).and_return(mock_claim_state_transitions) }

  it 'returns last claim state transition reason text' do
    is_expected.to eql 'last reason'
  end
end

RSpec.describe Claim::BaseClaimPresenter do
  let(:claim) { create(:advocate_claim) }
  subject(:presenter) { described_class.new(claim, view) }

  before do
    next if claim.remote?
    @first_defendant = claim.defendants.first
    @first_defendant.first_name = 'Mark'
    @first_defendant.last_name = "O'Reilly"
    @first_defendant.save!
    create(:defendant, first_name: 'Robert', last_name: 'Smith', claim: claim, order_for_judicial_apportionment: false)
    create(:defendant, first_name: 'Adam', last_name: 'Smith', claim: claim, order_for_judicial_apportionment: false)
  end

  describe '#show_sidebar?' do
    context 'when current step does NOT require sidebar' do
      before do
        expect(claim).to receive(:current_step).and_return(:defendants)
      end

      specify { expect(presenter.show_sidebar?).to be_falsey }
    end

    context 'when current step does require sidebar' do
      before do
        expect(claim).to receive(:current_step).and_return(:requires_sidebar_step)
      end

      specify { expect(presenter.show_sidebar?).to be_truthy }
    end
  end

  describe '#case_type_name' do
    context 'non redetermination or awaiting written reason' do
      it 'should display the case type name' do
        expect(subject.case_type_name).to eq(claim.case_type.name)
      end
    end

    context 'redetermination' do
      it 'should display the case type name with a redetermination label' do
        %w(submit allocate refuse redetermine allocate).each { |event| claim.send("#{event}!") }
        allow(claim).to receive(:opened_for_redetermination?).and_return(true)
        expect(subject.case_type_name).to eq(claim.case_type.name)
      end
    end

    context 'awaiting written reasons' do
      it 'should display the case type name with an awaiting written reasons label' do
        %w(submit allocate refuse await_written_reasons allocate).each { |event| claim.send("#{event}!") }
        allow(claim).to receive(:written_reasons_outstanding?).and_return(true)
        expect(subject.case_type_name).to eq(claim.case_type.name)
      end
    end
  end

  it '#defendant_names' do
    expect(subject.defendant_names).to eql("#{CGI.escapeHTML(@first_defendant.name)}, <br />Robert Smith, <br />Adam Smith")
  end

  it '#submitted_at' do
    claim.last_submitted_at = Time.current
    expect(subject.submitted_at).to eql(Time.current.strftime('%d/%m/%Y'))
    expect(subject.submitted_at(include_time: true)).to eql(Time.current.strftime('%d/%m/%Y %H:%M'))
  end

  it '#authorised_at' do
    claim.authorised_at = Time.current
    expect(subject.authorised_at).to eql(Time.current.strftime('%d/%m/%Y'))
    expect(subject.authorised_at(include_time: false)).to eql(Time.current.strftime('%d/%m/%Y'))
    expect(subject.authorised_at(include_time: true)).to eql(Time.current.strftime('%d/%m/%Y %H:%M'))
    expect { subject.authorised_at(rubbish: false) }.to raise_error(ArgumentError)
  end

  it '#unique_id' do
    expect(subject.unique_id).to eql("##{subject.id}")
  end

  describe '#case_number' do
    it 'returns a placeholder text when not provided' do
      subject.case_number = nil
      expect(subject.case_number).to eq('N/A')
    end

    it 'returns it when provided' do
      expect(subject.case_number).to eql(claim.case_number)
    end
  end

  it '#formatted_case_number' do
    subject.case_number = 'S20094903'
    expect(subject.formatted_case_number).to eql('S20 094 903')
  end

  describe '#valid_transitions' do
    it 'should list valid transitions from allocated' do
      claim.state = 'allocated'
      presenter = Claim::BaseClaimPresenter.new(claim, view)
      expect(presenter.valid_transitions).to eq(
        {
          part_authorised: 'Part authorised',
          authorised: 'Authorised',
          refused: 'Refused',
          rejected: 'Rejected',
          submitted: 'Submitted'
        }
      )
    end

    it 'should list valid transitions from allocated with include_submitted => false' do
      claim.state = 'allocated'
      presenter = Claim::BaseClaimPresenter.new(claim, view)
      expect(presenter.valid_transitions_for_detail_form).to eq(
        {
          part_authorised: 'Part authorised',
          authorised: 'Authorised',
          refused: 'Refused',
          rejected: 'Rejected'
        }
      )
    end

    it 'should list valid transitions from part_authorised' do
      claim.state = 'part_authorised'
      presenter = Claim::BaseClaimPresenter.new(claim, view)
      expect(presenter.valid_transitions).to eq({ :redetermination => 'Redetermination', :awaiting_written_reasons => 'Awaiting written reasons' })
    end
  end

  describe '#assessment_date' do
    context 'blank assessment' do
      it 'returns not yet assessed if there is no assessment' do
        expect(subject.assessment_date).to eq 'not yet assessed'
      end
    end

    let(:creation_date) { Time.new(2015, 8, 13, 14, 55, 23) }
    let(:assessment_date) { Time.new(2015, 9, 1, 12, 34, 55) }
    let(:first_redetermination_date)  { Time.new(2015, 9, 4, 7, 33, 22) }
    let(:second_redetermination_date) { Time.new(2015, 9, 9, 13, 33, 55) }
    let(:presenter) { Claim::BaseClaimPresenter.new(@claim, view) }

    context 'one assessment, no redeterminations' do
      it 'returns the updated date of the assessment' do
        travel_to(creation_date) { @claim = create :submitted_claim }
        travel_to(assessment_date) { @claim.assessment.update(fees: 100.0, expenses: 200.0) }
        expect(presenter.assessment_date).to eq '01/09/2015'
      end
    end

    context 'multiple redeterminations' do
      it 'returns creation date of last redetermination' do
        travel_to(creation_date) { @claim = create :submitted_claim }
        travel_to(assessment_date) { @claim.assessment.update(fees: 100.0, expenses: 200.0) }
        travel_to(first_redetermination_date) { @claim.redeterminations << Redetermination.new(fees: 110.0, expenses: 205.88) }
        travel_to(second_redetermination_date) { @claim.redeterminations << Redetermination.new(fees: 113.0, expenses: 208.88) }
        expect(presenter.assessment_date).to eq '09/09/2015'
      end
    end
  end

  describe 'assessment_fees' do
    it 'should return formatted assessment fees' do
      claim.assessment.update!(fees: 1234.56, expenses: 0.0, disbursements: 300.0)
      expect(subject.assessment_fees).to eq '£1,234.56'
    end
  end

  describe 'assessment_expenses' do
    it 'should return formatted assessment expenses' do
      claim.assessment.update!(fees: 0.0, expenses: 1234.56, disbursements: 300.0)
      expect(subject.assessment_expenses).to eq '£1,234.56'
    end
  end

  describe 'assessment_disbursements' do
    it 'should return formatted assessment disbursements' do
      claim.assessment.update!(fees: 0.0, expenses: 0.0, disbursements: 300.0)
      expect(subject.assessment_disbursements).to eq '£300.00'
    end
  end

  describe '#retrial' do
    it 'returns yes for case types like retrial' do
      claim.case_type = FactoryBot.create :case_type, :retrial
      expect(subject.retrial).to eql 'Yes'
    end

    it 'returns no for case types NOT like retrial' do
      claim.case_type = FactoryBot.create :case_type, :contempt
      expect(subject.retrial).to eql 'No'
    end

    it 'returns empty string when no case type' do
      claim.case_type = nil
      expect(subject.retrial).to be_blank
    end
  end

  describe '#any_judicial_apportionments' do
    it 'returns yes if any defendants have an order for judicial apportionment' do
      @first_defendant.update_attribute(:order_for_judicial_apportionment,true)
      expect(subject.any_judicial_apportionments).to eql 'Yes'
    end

    it 'returns no if no defendants have an order for judicial apportionment' do
      @first_defendant.update_attribute(:order_for_judicial_apportionment,false)
      expect(subject.any_judicial_apportionments).to eql 'No'
    end
  end

  # TODO: do currency converters need internationalisation??
  it '#amount_assessed' do
    claim.assessment.update(fees: 80.35, expenses: 19.65, disbursements: 52.48)
    expect(subject.assessment_total).to eql('£152.48')
  end

  context 'dynamically defined methods' do
    %w[expenses disbursements].each do |object_name|
      %w[total vat with_vat_net with_vat_gross without_vat_net without_vat_gross].each do |method|
        method_name = "#{object_name}_#{method}".to_sym
        it { is_expected.to respond_to(method_name) }

        describe "##{method_name}" do
          it 'returns currency format' do
            allow(claim).to receive(method_name).and_return 100
            expect(subject.send(method_name)).to match(/£\d+\.\d+/)
          end
        end
      end
    end
  end

  describe '#expenses_gross' do
    it 'returns total expenses and total of expense vat in currency format' do
      claim.expenses_total = 100
      claim.expenses_vat = 25
      expect(subject.expenses_gross).to eql('£125.00')
    end
  end

  describe '#disbursements_gross' do
    it 'returns total disbursements and total disbursment vat in currency format' do
      claim.disbursements_total = 100
      claim.disbursements_vat = 25
      expect(subject.disbursements_gross).to eql('£125.00')
    end
  end

  describe '#fees_total' do
    it 'returns total of all fees in currency format' do
      claim.fees_total = 100
      expect(subject.fees_total).to eql('£100.00')
    end
  end

  describe '#total_inc_vat' do
    it 'returns total of all fees and total of all fee vat in currency format' do
      claim.total = 60
      claim.vat_amount = 40
      expect(subject.total_inc_vat).to eql('£100.00')
    end
  end

  describe '#case_worker_email_addresses' do
    it 'returns comma separated string of case worker email address' do
      cw1 = build(:case_worker)
      cw2 = build(:case_worker)
      cw1.user.email = 'john@bigblackhole.com'
      cw2.user.email = 'bob@bigblackhole.com'
      claim.case_workers << cw1
      claim.case_workers << cw2
      expect(subject.case_worker_email_addresses).to eql('bob@bigblackhole.com, john@bigblackhole.com')
    end
  end

  describe '#caseworker_claim_id' do
    it 'returns claim id formatted for use in html label' do
      expect(subject.caseworker_claim_id).to eql("claim_ids_#{claim.id}")
    end
  end

  describe '#representation_order_details' do
    let(:claim) do
      claim = build(:claim)
      claim.defendants << defendant_1
      claim.defendants << defendant_2
      claim
    end

    let(:defendant_1) do
      defendant = build(:defendant)
      travel_to 5.days.ago do
        defendant.representation_orders = [
          build(:representation_order, representation_order_date: Date.new(2015,3,1), maat_reference: '222222'),
          build(:representation_order, representation_order_date: Date.new(2015,8,13), maat_reference: '333333')
        ]
      end
      defendant
    end

    let(:defendant_2) do
      defendant = build(:defendant)
      travel_to 2.days.ago do
        defendant.representation_orders = [build(:representation_order, representation_order_date: Date.new(2015,3,1), maat_reference: '444444')]
      end
      defendant
    end

    it 'should return an html safe string of all the dates' do
      expect(presenter.representation_order_details).to eq('01/03/2015 222222<br />13/08/2015 333333<br />01/03/2015 444444')
    end
  end

  it '#case_worker_names' do
    claim.case_workers << build(:case_worker, user: build(:user, first_name: 'Alexander', last_name: 'Bell'))
    claim.case_workers << build(:case_worker, user: build(:user, first_name: 'Louis', last_name: 'Pasteur'))
    expect(subject.case_worker_names).to eq('Alexander Bell, Louis Pasteur')
  end

  describe '#amount_assessed' do
    context 'when assessment present' do
      before do
        claim.submit!
        claim.allocate!
        claim.assessment.update!(fees: 100, expenses: 20.43, disbursements: 50.45)
        claim.authorise!
      end

      it 'display a currency formatted amount assessed' do
        expect(subject.amount_assessed).to match /£\d{3}\.\d{2}/
      end
    end

    context 'when no assessment present' do
      it 'displays "-"' do
        expect(subject.amount_assessed).to eq('-')
      end
    end
  end

  context 'defendant_summary' do
    let(:my_claim)  { Claim::AdvocateClaim.new }
    let(:presenter) { Claim::BaseClaimPresenter.new(my_claim, view) }

    context '3 defendants' do
      it 'returns name and intial of first defendant and count of additional defendants' do
        my_claim.defendants << Defendant.new(first_name: 'Stephen', last_name: 'Richards')
        my_claim.defendants << Defendant.new(first_name: 'Robert', last_name: 'Stirling')
        my_claim.defendants << Defendant.new(first_name: 'Stuart', last_name: 'Hollands')
        expect(presenter.defendant_name_and_initial).to eq 'S. Richards'
        expect(presenter.other_defendant_summary).to eq '+ 2 others'
      end
    end

    context '1 defendant' do
      it 'returns the name and initial of the only defendant' do
        my_claim.defendants << Defendant.new(first_name: 'Maria', last_name: 'Withers')
        expect(presenter.defendant_name_and_initial).to eq 'M. Withers'
      end
    end

    context '2 defendants' do
      it 'returns the name and initial of the first defendant + 1 other' do
        my_claim.defendants << Defendant.new(first_name: 'Maria', last_name: 'Withers')
        my_claim.defendants << Defendant.new(first_name: 'Angela', last_name: 'Jones')
        expect(presenter.defendant_name_and_initial).to eq 'M. Withers'
        expect(presenter.other_defendant_summary).to eq '+ 1 other'
      end
    end

    context 'no defendants' do
      it 'returns nil' do
        expect(presenter.defendant_name_and_initial).to be_nil
        expect(presenter.other_defendant_summary).to eq ''
      end
    end
  end

  it { is_expected.to respond_to :injection_error }
  it { is_expected.to respond_to :injection_error_summary }
  it { is_expected.to respond_to :injection_errors }
  it { is_expected.to respond_to :last_injection_attempt }
  it { is_expected.to respond_to :has_conference_and_views? }

  describe '#injection_error' do
    subject { presenter.injection_error }
    before { create(:injection_attempt, :with_errors, claim: claim) }

    it 'returns nil for inactive injection errors' do
      claim.injection_attempts.last.soft_delete
      is_expected.to be_nil
    end

    it 'returns single header message for active injection errors' do
      is_expected.to eql 'Claim not injected'
    end

    it 'yields a block passing the header message as an argument' do
      expect { |b| presenter.injection_error(&b) }.to yield_control.exactly(1).times
      expect { |b| presenter.injection_error(&b) }.to yield_with_args('Claim not injected')
    end
  end

  describe '#injection_errors' do
    subject { presenter.injection_errors }
    before do
      create(:injection_attempt, :with_errors, claim: claim)
    end

    it 'calls last error messages attribute of model' do
      injection_attempts = instance_double('injection_attempts')
      injection_attempt = instance_double('injection_attempt')
      expect(claim).to receive(:injection_attempts).at_least(:once).and_return(injection_attempts)
      expect(injection_attempts).to receive(:last).at_least(:once).and_return(injection_attempt)
      expect(injection_attempt).to receive(:active?).at_least(:once).and_return true
      expect(injection_attempt).to receive(:error_messages).at_least(:once)
      subject
    end

    it 'returns the last error messages array' do
      is_expected.to match_array(['injection error 1', 'injection error 2'])
    end
  end

  describe '#supplier_name' do
    subject { presenter.supplier_name }

    context 'AGFS' do
      it 'returns nil' do
        is_expected.to be_nil
      end
    end

    context 'LGFS' do
      let(:claim) { create(:litigator_claim) }
      let(:supplier) do
        SupplierNumber.find_by(supplier_number: claim.supplier_number)
      end

      it 'returns claim supplier\'s name' do
        is_expected.to eql supplier.name
      end
    end
  end

  describe '#supplier_postcode' do
    subject { presenter.supplier_postcode }

    context 'AGFS' do
      it 'returns nil' do
        is_expected.to be_nil
      end
    end

    context 'LGFS' do
      let(:claim) { create(:litigator_claim) }
      let(:supplier) { SupplierNumber.find_by(supplier_number: claim.supplier_number) }

      it 'returns claim suppliers postcode' do
        is_expected.to_not be_nil
        is_expected.to eql supplier.postcode
      end
    end
  end

  describe '#supplier_name_with_postcode' do
    subject { presenter.supplier_name_with_postcode }

    context 'AGFS' do
      it 'returns nil' do
        is_expected.to be_nil
      end
    end

    context 'LGFS' do
      let(:claim) { create(:litigator_claim) }
      let(:supplier) { SupplierNumber.find_by(supplier_number: claim.supplier_number) }

      context 'when claim supplier has name and postcode' do
        it 'returns name and postcode' do
          is_expected.to_not be_nil
          is_expected.to eql "#{supplier.name} (#{supplier.postcode})"
        end
      end

      context 'when claim supplier has name but NOT postcode' do
        before { supplier.update(postcode: nil) }

        it 'returns name' do
          is_expected.to eql "#{supplier.name}"
        end
      end

      context 'when claim supplier has no name or postcode' do
        before { supplier.update(name: nil, postcode: nil) }
        it { is_expected.to be_nil }
      end
    end
  end

  describe '#has_conference_and_views?' do
    subject { presenter.has_conference_and_views? }
    let!(:fee) { create(:basic_fee, :cav_fee, claim: claim, quantity: quantity, rate: rate) }

    before { claim.reload }

    context 'when the claims CAV fee is populated' do
      let(:rate) { 1 }
      let(:quantity) { 25 }

      it { is_expected.to be true }
    end

    context 'when the claims CAV fee is empty' do
      let(:rate) { 0 }
      let(:quantity) { 0 }

      it { is_expected.to be false }
    end
  end

  describe '#requires_interim_claim_info?' do
    subject { presenter.requires_interim_claim_info? }
    it { is_expected.to be_falsey }
  end

  describe '#mandatory_case_details?' do
    it 'returns truthy when claim has case type, court and case number' do
      expect(claim).to receive(:case_type).and_return 'a case type'
      expect(claim).to receive(:court).and_return 'a court'
      expect(claim).to receive(:case_number).and_return 'a case number'
      expect(presenter.mandatory_case_details?).to be_truthy
    end

    it ' returns falsey when claim is missing one of case type, court or case number' do
      expect(claim).to receive(:case_type).and_return 'a case type'
      expect(claim).to receive(:court).and_return 'a court'
      expect(claim).to receive(:case_number).and_return nil
      expect(presenter.mandatory_case_details?).to be_falsey
    end
  end

  describe '#mandatory_supporting_evidence?' do
    it 'returns truthy when claim has disk evidence, documents or evidence checklist item' do
      expect(claim).to receive(:disk_evidence).and_return false
      expect(claim).to receive(:documents).and_return []
      expect(claim).to receive(:evidence_checklist_ids).and_return [1]
      expect(presenter.mandatory_supporting_evidence?).to be_truthy
    end

    it 'returns falsey when claim has NO disk evidence, documents or evidence checklist item' do
      expect(claim).to receive(:disk_evidence).and_return false
      expect(claim).to receive(:documents).and_return []
      expect(claim).to receive(:evidence_checklist_ids).and_return []
      expect(presenter.mandatory_supporting_evidence?).to be_falsey
    end
  end

  describe '#reason_text' do
    subject { presenter.reason_text }
    include_examples 'last claim state transition reason_text'
  end

  describe '#reject_reason_text' do
    subject { presenter.reject_reason_text }
    include_examples 'last claim state transition reason_text'
  end

  describe '#refuse_reason_text' do
    subject { presenter.refuse_reason_text }
    include_examples 'last claim state transition reason_text'
  end

  describe '#claim_state' do
    subject { presenter.claim_state }

    context 'when opened for redetermination' do
      before { allow(claim).to receive(:opened_for_redetermination?).and_return true }
      it { is_expected.to eql 'Redetermination' }
    end

    context 'when written reasons outstanding' do
      before { allow(claim).to receive(:written_reasons_outstanding?).and_return true }
      it { is_expected.to eql 'Awaiting written reasons' }
    end

    context 'when not opened for redetermination nor written reasons outstanding' do
      before do
        allow(claim).to receive(:opened_for_redetermination?).and_return false
        allow(claim).to receive(:written_reasons_outstanding?).and_return false
      end
      it { is_expected.to be_blank }
    end
  end

  describe '#submitted_at_short' do
    subject { presenter.submitted_at_short }
    it 'returns short date formatted string of #last_submitted_at' do
      expect(claim).to receive(:last_submitted_at).and_return DateTime.parse('2019-03-31 09:38:00.000000')
      is_expected.to eql '31/03/19'
    end
  end

  describe '#trial_concluded' do
    subject { presenter.trial_concluded }

    context 'when no claim#trial_concluded_at' do
      before { allow(claim).to receive(:trial_concluded_at).and_return nil }
      it 'returns text' do
        is_expected.to eql 'not specified'
      end
    end

    context 'when claim#trial_concluded_at' do
      before { allow(claim).to receive(:trial_concluded_at).and_return DateTime.parse('2019-03-31 09:38:00.000000') }
      it 'returns app specific date string format' do
        is_expected.to eql '31/03/2019'
      end
    end
  end

  describe '#has_messages?' do
    subject { presenter.has_messages? }

    context 'non-remote claims' do
      before { allow(claim).to receive(:remote?).and_return false }

      it 'returns true if there are any messages' do
        expect(claim).to receive(:messages).and_return [instance_double(Message)]
        is_expected.to be_truthy
      end

      it 'returns false if there are no messages' do
        expect(claim).to receive(:messages).and_return []
        is_expected.to be_falsey
      end
    end

    context 'remote claims' do
      let(:claim) { double(::Remote::Claim, remote?: true) }

      it 'returns true for positive message count' do
        allow(claim).to receive(:messages_count).and_return 2
        is_expected.to be_truthy
      end

      it 'returns false for nil or zero message count' do
        allow(claim).to receive(:messages_count).and_return nil
        is_expected.to be_falsey
      end
    end
  end

  describe '#raw_misc_fees_total' do
    it 'sends message to claim' do
      expect(claim).to receive(:calculate_fees_total).with(:misc_fees).and_return 101.00
      expect(presenter.raw_misc_fees_total).to eql 101.00
    end
  end

  describe '#raw_fixed_fees_total' do
    it 'sends message to claim' do
      expect(claim).to receive(:fixed_fees)
      presenter.raw_fixed_fees_total
    end
  end

  describe '#raw_expenses_total' do
    it 'sends message to claim' do
      expect(claim).to receive(:expenses_total)
      presenter.raw_expenses_total
    end
  end

  describe '#raw_expenses_vat' do
    it 'sends message to claim' do
      expect(claim).to receive(:expenses_vat)
      presenter.raw_expenses_vat
    end
  end

  describe '#raw_disbursements_total' do
    it 'sends message to claim' do
      expect(claim).to receive(:disbursements_total)
      presenter.raw_disbursements_total
    end
  end

  describe '#raw_disbursements_vat' do
    it 'sends message to claim' do
      expect(claim).to receive(:disbursements_vat)
      presenter.raw_disbursements_vat
    end
  end

  describe '#raw_vat_amount' do
    it 'sends message to claim' do
      expect(claim).to receive(:vat_amount)
      presenter.raw_vat_amount
    end
  end

  describe '#raw_total_inc' do
    it 'sends messages to claim' do
      expect(claim).to receive(:total).and_return 120.00
      expect(claim).to receive(:vat_amount).and_return 24.00
      expect(presenter.raw_total_inc).to eql 144.00
    end
  end

  describe '#raw_total_excl' do
    it 'sends message to claim' do
      expect(claim).to receive(:total)
      presenter.raw_total_excl
    end
  end

  describe '#can_have_expenses?' do
    specify { expect(presenter.can_have_expenses?).to be_truthy }
  end

  describe '#can_have_disbursements?' do
    specify { expect(presenter.can_have_disbursements?).to be_truthy }
  end

  describe '#display_days?' do
    specify { expect(presenter.display_days?).to be_falsey }
  end

  describe '#display_case_type?' do
    subject { presenter.display_case_type? }

    let(:external_user) { build(:external_user) }
    let(:case_worker) { build(:case_worker) }

    context 'when claim has no case type' do
      let(:claim) { create(:claim, case_type: nil) }

      context 'when user is caseworker' do
        before { allow(view).to receive(:current_user).and_return(case_worker.user) }
        it { is_expected.to be_falsey }
      end

      context 'when user is external_user' do
        before { allow(view).to receive(:current_user).and_return(external_user.user) }
        it { is_expected.to be_falsey }
      end
    end

    context 'when claim delegates case type' do
      let(:claim) { create(:advocate_hardship_claim, case_type: nil, case_stage: build(:case_stage, :trial_not_concluded)) }

      it 'case type is expected to be truthy' do
        expect(claim.case_type).to be_truthy
      end

      context 'when user is caseworker' do
        before { allow(view).to receive(:current_user).and_return(case_worker.user) }
        it { is_expected.to be_truthy }
      end

      context 'when user is external_user' do
        before { allow(view).to receive(:current_user).and_return(external_user.user) }
        it { is_expected.to be_falsey }
      end
    end

    context 'when claim has a non-delegated case type' do
      let(:claim) { create(:claim, case_type: build(:case_type)) }

      context 'when user is caseworker' do
        before { allow(view).to receive(:current_user).and_return(case_worker.user) }
        it { is_expected.to be_truthy }
      end

      context 'when user is external_user' do
        before { allow(view).to receive(:current_user).and_return(external_user.user) }
        it { is_expected.to be_truthy }
      end
    end
  end

  describe 'calculate #misc_fees' do
    before do
      allow(presenter).to receive(:raw_misc_fees_total).and_return 10.0
      allow(claim).to receive(:created_at).and_return Date.today
      allow(claim).to receive(:apply_vat?).and_return true
    end

    it '#raw_misc_fees_vat' do
      expect(presenter.raw_misc_fees_vat).to eq(2.0)
    end

    it 'returns #raw_misc_fees_gross' do
      allow(presenter).to receive(:raw_misc_fees_vat).and_return 2.0
      expect(presenter.raw_misc_fees_gross).to eq(12.0)
    end

    it 'returns #misc_fees_vat with the associated currency' do
      expect(presenter.misc_fees_vat).to eq('£2.00')
    end

    it 'returns #misc_fees_gross with the associated currency' do
      expect(presenter.misc_fees_gross).to eq('£12.00')
    end
  end

  describe 'calculate #fixed_fees' do
    before do
      allow(presenter).to receive(:raw_fixed_fees_total).and_return 10.0
      allow(claim).to receive(:created_at).and_return Date.today
      allow(claim).to receive(:apply_vat?).and_return true
    end

    it '#raw_fixed_fees_vat' do
      expect(presenter.raw_fixed_fees_vat).to eq(2.0)
    end

    it 'returns #raw_fixed_fees_gross' do
      allow(presenter).to receive(:raw_fixed_fees_vat).and_return 2.0
      expect(presenter.raw_fixed_fees_gross).to eq(12.0)
    end

    it 'returns #fixed_fees_vat with the associated currency' do
      expect(presenter.fixed_fees_vat).to eq('£2.00')
    end

    it 'returns #fixed_fees_gross with the associated currency' do
      expect(presenter.fixed_fees_gross).to eq('£12.00')
    end
  end

  describe '#has_clar_fees?' do
    subject { presenter.has_clar_fees? }
    let!(:fee) { create(:misc_fee, :miphc_fee, claim: claim, quantity: quantity, rate: rate) }

    before { claim.reload }

    context 'when the claims CLAR fee is populated' do
      let(:rate) { 1 }
      let(:quantity) { 3 }

      it { is_expected.to be true }
    end

    context 'when the claims CLAR fee is empty' do
      let(:rate) { 0 }
      let(:quantity) { 0 }

      it { is_expected.to be false }
    end
  end

  describe '#eligible_misc_fee_type_options_for_select' do
    subject { presenter.eligible_misc_fee_type_options_for_select }

    let!(:mispf_fee_type) { create(:misc_fee_type, :mispf) }

    it { is_expected.to be_a Array }
    it {
      is_expected.to include(
                          [
                            mispf_fee_type.description,
                            mispf_fee_type.id,
                            data: { unique_code: mispf_fee_type.unique_code }
                          ]
                        )
    }
  end
end
