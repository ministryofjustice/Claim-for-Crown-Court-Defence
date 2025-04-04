require 'rails_helper'
require 'cgi'

METHOD_NAMES = %w[total vat with_vat_net with_vat_gross without_vat_net without_vat_gross].freeze

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
  subject(:presenter) { described_class.new(claim, view) }

  let(:claim) { create(:advocate_claim) }
  let(:first_defendant) { claim.defendants.first }

  before do
    next if claim.remote?
    first_defendant.update!(first_name: 'Mark', last_name: "O'Reilly")
    create(:defendant, first_name: 'Robert', last_name: 'Smith', claim:, order_for_judicial_apportionment: false)
    create(:defendant, first_name: 'Adam', last_name: 'Smith', claim:, order_for_judicial_apportionment: false)
  end

  describe '#show_sidebar?' do
    subject { presenter.show_sidebar? }

    context 'when current step does NOT require sidebar' do
      before { allow(claim).to receive(:current_step).and_return(:defendants) }

      it { is_expected.to be_falsey }
    end

    context 'when current step does require sidebar' do
      before { allow(claim).to receive(:current_step).and_return(:requires_sidebar_step) }

      it { is_expected.to be_truthy }
    end
  end

  describe '#case_type_name' do
    context 'without a redetermination or awaiting written reasons' do
      it { expect(presenter.case_type_name).to eq(claim.case_type.name) }
      it { expect(presenter.claim_state).to be_blank }
    end

    context 'with a redetermination' do
      before do
        %w[submit allocate refuse redetermine allocate].each { |event| claim.send(:"#{event}!") }
        allow(claim).to receive(:opened_for_redetermination?).and_return(true)
      end

      it { expect(presenter.case_type_name).to eq(claim.case_type.name) }
      it { expect(presenter.claim_state).to eq('Redetermination') }
    end

    context 'with awaiting written reasons' do
      before do
        %w[submit allocate refuse await_written_reasons allocate].each { |event| claim.send(:"#{event}!") }
        allow(claim).to receive(:written_reasons_outstanding?).and_return(true)
      end

      it { expect(presenter.case_type_name).to eq(claim.case_type.name) }
      it { expect(presenter.claim_state).to eq('Awaiting written reasons') }
    end
  end

  describe '#defendant_names' do
    before { claim.reload }

    it do
      expect(presenter.defendant_names)
        .to eql("#{CGI.escapeHTML(first_defendant.name)}, <br>Robert Smith, <br>Adam Smith")
    end
  end

  describe '#submitted_at' do
    before do
      freeze_time
      claim.update!(last_submitted_at: Time.current)
    end

    it { expect(presenter.submitted_at).to eql(Time.current.strftime('%d/%m/%Y')) }
    it { expect(presenter.submitted_at(include_time: true)).to eql(Time.current.strftime('%d/%m/%Y %H:%M')) }
  end

  describe '#authorised_at' do
    before do
      freeze_time
      claim.update!(authorised_at: Time.current)
    end

    it { expect(presenter.authorised_at).to eql(Time.current.strftime('%d/%m/%Y')) }
    it { expect(presenter.authorised_at(include_time: false)).to eql(Time.current.strftime('%d/%m/%Y')) }
    it { expect(presenter.authorised_at(include_time: true)).to eql(Time.current.strftime('%d/%m/%Y %H:%M')) }
    it { expect { presenter.authorised_at(rubbish: false) }.to raise_error(ArgumentError) }
  end

  describe '#unique_id' do
    it { expect(presenter.unique_id).to eql("##{presenter.id}") }
  end

  describe '#case_number' do
    it { expect(presenter.case_number).to eql(claim.case_number) }

    context 'when case_number is not provided' do
      before { presenter.update!(case_number: nil) }

      it { expect(presenter.case_number).to eq('N/A') }
    end
  end

  describe '#formatted_case_number' do
    before { presenter.update!(case_number: 'S20094903') }

    it { expect(presenter.formatted_case_number).to eql('S20 094 903') }
  end

  describe '#valid_transitions' do
    let(:valid_transitions) do
      {
        part_authorised: 'Part authorised',
        authorised: 'Authorised',
        refused: 'Refused',
        rejected: 'Rejected',
        submitted: 'Submitted'
      }
    end

    before { claim.update!(state: 'allocated') }

    it { expect(presenter.valid_transitions).to eq(valid_transitions) }
  end

  describe '#valid_transitions_for_detail_form' do
    let(:valid_transitions) do
      {
        part_authorised: 'Part authorised',
        authorised: 'Authorised',
        refused: 'Refused',
        rejected: 'Rejected'
      }
    end

    context 'when the claim is allocated' do
      before { claim.update!(state: 'allocated') }

      it { expect(presenter.valid_transitions_for_detail_form).to eq(valid_transitions) }
    end

    context 'when the claim is part_authorised' do
      before do
        claim.assessment.update!(fees: 10.00)
        claim.update!(state: 'part_authorised')
      end

      it do
        expect(presenter.valid_transitions)
          .to eq({ redetermination: 'Redetermination', awaiting_written_reasons: 'Awaiting written reasons' })
      end
    end
  end

  describe '#assessment_date' do
    let(:assessment_date) { Time.zone.local(2015, 9, 1, 12, 34, 55) }
    let(:claim) { create(:submitted_claim, created_at: Time.zone.local(2015, 8, 13, 14, 55, 23)) }

    context 'with a blank assessment' do
      it { expect(presenter.assessment_date).to eq 'not yet assessed' }
    end

    context 'with one assessment, no redeterminations' do
      before do
        claim.assessment.update!(fees: 100.0, expenses: 200.0, created_at: assessment_date, updated_at: assessment_date)
      end

      it { expect(presenter.assessment_date).to eq '01/09/2015' }
    end

    context 'with multiple redeterminations' do
      let(:first_redetermination) { create(:redetermination, created_at: Time.zone.local(2015, 9, 4, 7, 33, 22)) }
      let(:second_redetermination) { create(:redetermination, created_at: Time.zone.local(2015, 9, 9, 13, 33, 55)) }

      before do
        claim.assessment.update!(fees: 100.0, expenses: 200.0, created_at: assessment_date, updated_at: assessment_date)
        claim.redeterminations = [first_redetermination, second_redetermination]
      end

      it { expect(presenter.assessment_date).to eq '09/09/2015' }
    end
  end

  describe '#assessment_fees' do
    before { claim.assessment.update!(fees: 1234.56, expenses: 0.0, disbursements: 300.0) }

    it { expect(presenter.assessment_fees).to eq '£1,234.56' }
  end

  describe '#assessment_expenses' do
    before { claim.assessment.update!(fees: 0.0, expenses: 1234.56, disbursements: 300.0) }

    it { expect(presenter.assessment_expenses).to eq '£1,234.56' }
  end

  describe '#assessment_disbursements' do
    before { claim.assessment.update!(fees: 0.0, expenses: 0.0, disbursements: 300.0) }

    it { expect(presenter.assessment_disbursements).to eq '£300.00' }
  end

  describe '#retrial' do
    context 'when the case type is retrial' do
      before { claim.update!(case_type: create(:case_type, :retrial)) }

      it { expect(presenter.retrial).to eql 'Yes' }
    end

    context 'when the case type is not retrial' do
      before { claim.update!(case_type: create(:case_type, :contempt)) }

      it { expect(presenter.retrial).to eql 'No' }
    end

    context 'when there is no case type' do
      before { claim.update!(case_type: nil) }

      it { expect(presenter.retrial).to be_blank }
    end
  end

  describe '#any_judicial_apportionments' do
    context 'when any defendant has an order for judicial apportionment' do
      before { first_defendant.update!(order_for_judicial_apportionment: true) }

      it { expect(presenter.any_judicial_apportionments).to eql 'Yes' }
    end

    context 'when no defendant has an order for judicial apportionment' do
      it { expect(presenter.any_judicial_apportionments).to eql 'No' }
    end
  end

  # TODO: do currency converters need internationalisation??
  describe '#assessment_total' do
    before { claim.assessment.update(fees: 80.35, expenses: 19.65, disbursements: 52.48) }

    it { expect(presenter.assessment_total).to eql('£152.48') }
  end

  describe 'dynamically defined methods' do
    %w[expenses disbursements].each do |object_name|
      METHOD_NAMES.each do |method|
        method_name = :"#{object_name}_#{method}"
        it { is_expected.to respond_to(method_name) }

        describe "##{method_name}" do
          it 'returns currency format' do
            allow(claim).to receive(method_name).and_return 100
            expect(presenter.send(method_name)).to match(/£\d+\.\d+/)
          end
        end
      end
    end
  end

  describe '#expenses_gross' do
    before { claim.update!(expenses_total: 100, expenses_vat: 25) }

    it { expect(presenter.expenses_gross).to eql('£125.00') }
  end

  describe '#disbursements_gross' do
    before { claim.update!(disbursements_total: 100, disbursements_vat: 25) }

    it { expect(presenter.disbursements_gross).to eql('£125.00') }
  end

  describe '#fees_total' do
    before { claim.update!(fees_total: 100) }

    it { expect(presenter.fees_total).to eql('£100.00') }
  end

  describe '#total_inc_vat' do
    before { claim.update!(total: 60, fees_vat: 40) }

    it { expect(presenter.total_inc_vat).to eql('£100.00') }
  end

  describe '#case_worker_email_addresses' do
    let(:first_case_worker) { build(:case_worker) }
    let(:second_case_worker) { build(:case_worker) }

    before do
      first_case_worker.user.update!(email: 'john@bigblackhole.com')
      second_case_worker.user.update!(email: 'bob@bigblackhole.com')
      claim.case_workers = [first_case_worker, second_case_worker]
    end

    it { expect(presenter.case_worker_email_addresses).to eql('bob@bigblackhole.com, john@bigblackhole.com') }
  end

  describe '#caseworker_claim_id' do
    it { expect(presenter.caseworker_claim_id).to eql("claim_ids_#{claim.id}") }
  end

  describe '#representation_order_details' do
    let(:claim) do
      build(:claim).tap do |claim|
        claim.defendants = [defendant_added_first, defendant_added_second]
      end
    end

    let(:defendant_added_first) do
      build(:defendant).tap do |defendant|
        travel_to 5.days.ago do
          defendant.representation_orders = [
            build(:representation_order, representation_order_date: Date.new(2015, 3, 1), maat_reference: '222222'),
            build(:representation_order, representation_order_date: Date.new(2015, 8, 13), maat_reference: '333333')
          ]
        end
      end
    end

    let(:defendant_added_second) do
      build(:defendant).tap do |defendant|
        travel_to 2.days.ago do
          defendant.representation_orders = [build(:representation_order,
                                                   representation_order_date: Date.new(2015, 3, 1),
                                                   maat_reference: '444444')]
        end
      end
    end

    it 'returns a string of all the dates' do
      expect(presenter.representation_order_details).to eq(
        '01/03/2015 222222<br>13/08/2015 333333<br>01/03/2015 444444'
      )
    end
  end

  describe '#case_worker_names' do
    before do
      claim.case_workers = [
        build(:case_worker, user: build(:user, first_name: 'Alexander', last_name: 'Bell')),
        build(:case_worker, user: build(:user, first_name: 'Louis', last_name: 'Pasteur'))
      ]
    end

    it { expect(presenter.case_worker_names).to eq('Alexander Bell, Louis Pasteur') }
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
        expect(presenter.amount_assessed).to match(/£\d{3}\.\d{2}/)
      end
    end

    context 'when no assessment present' do
      it 'displays "-"' do
        expect(presenter.amount_assessed).to eq('-')
      end
    end
  end

  describe 'displaying a defendant_summary' do
    let(:my_claim)  { Claim::AdvocateClaim.new }
    let(:presenter) { described_class.new(my_claim, view) }

    context 'with no defendants' do
      it { expect(presenter.defendant_name_and_initial).to be_nil }
      it { expect(presenter.other_defendant_summary).to be_blank }
      it { expect(presenter.all_defendants_name_and_initial).to eq '' }
    end

    context 'with 1 defendant' do
      before { my_claim.defendants = [Defendant.new(first_name: 'Maria', last_name: 'Withers')] }

      it { expect(presenter.defendant_name_and_initial).to eq 'M. Withers' }
      it { expect(presenter.other_defendant_summary).to be_blank }
      it { expect(presenter.all_defendants_name_and_initial).to eq 'M. Withers' }
    end

    context 'with 2 defendants' do
      before do
        my_claim.defendants = [
          Defendant.new(first_name: 'Maria', last_name: 'Withers'),
          Defendant.new(first_name: 'Angela', last_name: 'Jones')
        ]
      end

      it { expect(presenter.defendant_name_and_initial).to eq 'M. Withers' }
      it { expect(presenter.other_defendant_summary).to eq '+ 1 other' }
      it { expect(presenter.all_defendants_name_and_initial).to eq 'M. Withers, A. Jones' }
    end

    context 'with 3 defendants' do
      before do
        my_claim.defendants = [
          Defendant.new(first_name: 'Stephen', last_name: 'Richards'),
          Defendant.new(first_name: 'Robert', last_name: 'Stirling'),
          Defendant.new(first_name: 'Stuart', last_name: 'Hollands')
        ]
      end

      it { expect(presenter.defendant_name_and_initial).to eq 'S. Richards' }
      it { expect(presenter.other_defendant_summary).to eq '+ 2 others' }
      it { expect(presenter.all_defendants_name_and_initial).to eq 'S. Richards, R. Stirling, S. Hollands' }
    end
  end

  it { is_expected.to respond_to :injection_error }
  it { is_expected.to respond_to :injection_error_summary }
  it { is_expected.to respond_to :injection_errors }
  it { is_expected.to respond_to :last_injection_attempt }
  it { is_expected.to respond_to :has_conference_and_views? }

  describe '#injection_error' do
    subject { presenter.injection_error }

    before { create(:injection_attempt, :with_errors, claim:) }

    context 'with injection errors' do
      it { is_expected.to eql 'Claim not injected' }
      it { expect { |b| presenter.injection_error(&b) }.to yield_control.exactly(1).times }
      it { expect { |b| presenter.injection_error(&b) }.to yield_with_args('Claim not injected') }
    end

    context 'when injection errors are inactive' do
      before { claim.injection_attempts.last.soft_delete }

      it { is_expected.to be_nil }
    end
  end

  describe '#injection_errors' do
    subject(:injection_errors) { presenter.injection_errors }

    let(:injection_attempts) { [instance_double(InjectionAttempt)] }
    let(:injection_attempt) { instance_double(InjectionAttempt) }

    before { create(:injection_attempt, :with_errors, claim:) }

    context 'when stubbing calls to injection_attempts' do
      before do
        allow(claim).to receive(:injection_attempts).at_least(:once).and_return(injection_attempts)
        allow(injection_attempts).to receive(:last).at_least(:once).and_return(injection_attempt)
        allow(injection_attempt).to receive(:active?).at_least(:once).and_return true
      end

      it 'calls last error messages attribute of model' do
        allow(injection_attempt).to receive(:error_messages)
        injection_errors
        expect(injection_attempt).to have_received(:error_messages).at_least(:once)
      end
    end

    it 'returns the last error messages array' do
      is_expected.to contain_exactly('injection error 1', 'injection error 2')
    end
  end

  describe '#supplier_name' do
    subject { presenter.supplier_name }

    context 'when the claim is AGFS' do
      it { is_expected.to be_nil }
    end

    context 'when the claim is LGFS' do
      let(:claim) { create(:litigator_claim) }
      let(:supplier) { SupplierNumber.find_by(supplier_number: claim.supplier_number) }

      it { is_expected.to eql supplier.name }
    end
  end

  describe '#supplier_postcode' do
    subject { presenter.supplier_postcode }

    context 'when the claim is AGFS' do
      it { is_expected.to be_nil }
    end

    context 'when the claim is LGFS' do
      let(:claim) { create(:litigator_claim) }
      let(:supplier) { SupplierNumber.find_by(supplier_number: claim.supplier_number) }

      it { is_expected.to eql supplier.postcode }
    end
  end

  describe '#supplier_name_with_postcode' do
    subject { presenter.supplier_name_with_postcode }

    context 'when the claim is AGFS' do
      it { is_expected.to be_nil }
    end

    context 'when the claim is LGFS' do
      let(:claim) { create(:litigator_claim) }
      let(:supplier) { SupplierNumber.find_by(supplier_number: claim.supplier_number) }

      context 'when claim supplier has name and postcode' do
        it { is_expected.to eql "#{supplier.name} (#{supplier.postcode})" }
      end

      context 'when claim supplier has name but NOT postcode' do
        before { supplier.update(postcode: nil) }

        it { is_expected.to eql supplier.name }
      end

      context 'when claim supplier has no name or postcode' do
        before { supplier.update(name: nil, postcode: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#has_conference_and_views?' do
    subject { presenter.has_conference_and_views? }

    before do
      create(:basic_fee, :cav_fee, claim:, quantity:, rate:)
      claim.reload
    end

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
    subject { presenter.mandatory_case_details? }

    before { allow(claim).to receive_messages(case_type: 'a case type', court: 'a court') }

    context 'when claim has case type, court and case number' do
      before { allow(claim).to receive(:case_number).and_return 'a case number' }

      it { is_expected.to be_truthy }
    end

    context 'when claim is missing one of case type, court or case number' do
      before { allow(claim).to receive(:case_number).and_return nil }

      it { is_expected.to be_falsey }
    end
  end

  describe '#mandatory_supporting_evidence?' do
    subject { presenter.mandatory_supporting_evidence? }

    before { allow(claim).to receive_messages(disk_evidence: false, court: []) }

    context 'when claim has disk evidence, documents or evidence checklist item' do
      before { allow(claim).to receive(:evidence_checklist_ids).and_return [1] }

      it { is_expected.to be_truthy }
    end

    context 'when claim has NO disk evidence, documents or evidence checklist item' do
      before { allow(claim).to receive(:evidence_checklist_ids).and_return [] }

      it { is_expected.to be_falsey }
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
        allow(claim).to receive_messages(opened_for_redetermination?: false, written_reasons_outstanding?: false)
      end

      it { is_expected.to be_blank }
    end
  end

  describe '#submitted_at_short' do
    subject { presenter.submitted_at_short }

    before { allow(claim).to receive(:last_submitted_at).and_return DateTime.parse('2019-03-31 09:38:00.000000') }

    it { is_expected.to eql '31/03/19' }
  end

  describe '#trial_concluded' do
    subject { presenter.trial_concluded }

    context 'when no claim#trial_concluded_at' do
      before { allow(claim).to receive(:trial_concluded_at).and_return nil }

      it { is_expected.to eql 'not specified' }
    end

    context 'when claim#trial_concluded_at' do
      before { allow(claim).to receive(:trial_concluded_at).and_return DateTime.parse('2019-03-31 09:38:00.000000') }

      it { is_expected.to eql '31/03/2019' }
    end
  end

  describe '#has_messages?' do
    subject { presenter.has_messages? }

    context 'when the claim is non-remote' do
      before { allow(claim).to receive(:remote?).and_return false }

      context 'when there are messages' do
        before { allow(claim).to receive(:messages).and_return [instance_double(Message)] }

        it { is_expected.to be_truthy }
      end

      context 'when there are no messages' do
        before { allow(claim).to receive(:messages).and_return [] }

        it { is_expected.to be_falsey }
      end
    end

    context 'when the claim is remote' do
      let(:claim) { instance_double(Remote::Claim, remote?: true) }

      context 'when message count is positive' do
        before { allow(claim).to receive(:messages_count).and_return 2 }

        it { is_expected.to be_truthy }
      end

      context 'when message count is zero' do
        before { allow(claim).to receive(:messages_count).and_return 0 }

        it { is_expected.to be_falsey }
      end

      context 'when message count is nil' do
        before { allow(claim).to receive(:messages_count).and_return nil }

        it { is_expected.to be_falsey }
      end
    end
  end

  describe '#raw_misc_fees_total' do
    before { allow(claim).to receive(:calculate_fees_total).with(:misc_fees).and_return 101.00 }

    it { expect(presenter.raw_misc_fees_total).to eq 101.00 }
  end

  describe '#raw_fixed_fees_total' do
    before { allow(claim).to receive(:calculate_fees_total).with(:fixed_fees).and_return 101.00 }

    it { expect(presenter.raw_fixed_fees_total).to eq 101.00 }
  end

  describe '#raw_expenses_total' do
    before { allow(claim).to receive(:expenses_total).and_return 101.00 }

    it { expect(presenter.raw_expenses_total).to eq 101.00 }
  end

  describe '#raw_expenses_vat' do
    before { allow(claim).to receive(:expenses_vat).and_return 20.20 }

    it { expect(presenter.raw_expenses_vat).to eq 20.20 }
  end

  describe '#raw_disbursements_total' do
    before { allow(claim).to receive(:disbursements_total).and_return 101.00 }

    it { expect(presenter.raw_disbursements_total).to eq 101.00 }
  end

  describe '#raw_disbursements_vat' do
    before { allow(claim).to receive(:disbursements_vat).and_return 20.20 }

    it { expect(presenter.raw_disbursements_vat).to eq 20.20 }
  end

  describe '#raw_vat_amount' do
    before { allow(claim).to receive(:vat_amount).and_return 20.20 }

    it { expect(presenter.raw_vat_amount).to eq 20.20 }
  end

  describe '#raw_total_inc' do
    before { allow(claim).to receive_messages(total: 120.00, vat_amount: 24.00) }

    it { expect(presenter.raw_total_inc).to eq 144.00 }
  end

  describe '#raw_total_excl' do
    before { allow(claim).to receive_messages(total: 120.00, vat_amount: 24.00) }

    it { expect(presenter.raw_total_excl).to eq 120.00 }
  end

  describe '#can_have_disbursements?' do
    subject { presenter.can_have_disbursements? }

    it { is_expected.to be_truthy }
  end

  describe '#display_days?' do
    subject { presenter.display_days? }

    it { is_expected.to be_falsey }
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
      let(:claim) do
        create(:advocate_hardship_claim, case_type: nil, case_stage: build(:case_stage, :trial_not_concluded))
      end

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
      allow(claim).to receive_messages(created_at: Time.zone.today, apply_vat?: true, calculate_fees_total: 10.00)
    end

    it { expect(presenter.raw_misc_fees_vat).to eq(2.0) }
    it { expect(presenter.raw_misc_fees_gross).to eq(12.0) }
    it { expect(presenter.misc_fees_vat).to eq('£2.00') }
    it { expect(presenter.misc_fees_gross).to eq('£12.00') }
  end

  describe 'calculate #fixed_fees' do
    before do
      allow(claim).to receive_messages(created_at: Time.zone.today, apply_vat?: true, calculate_fees_total: 10.00)
    end

    it { expect(presenter.raw_fixed_fees_vat).to eq(2.0) }
    it { expect(presenter.raw_fixed_fees_gross).to eq(12.0) }
    it { expect(presenter.fixed_fees_vat).to eq('£2.00') }
    it { expect(presenter.fixed_fees_gross).to eq('£12.00') }
  end

  describe '#has_clar_fees?' do
    subject { presenter.has_clar_fees? }

    before do
      create(:misc_fee, :miphc_fee, claim:, quantity:, rate:)
      claim.reload
    end

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
        [mispf_fee_type.description, mispf_fee_type.id, { data: { unique_code: mispf_fee_type.unique_code } }]
      )
    }
  end
end
