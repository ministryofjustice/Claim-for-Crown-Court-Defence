require 'rails_helper'
require 'support/shared_examples_for_claim_types'

class MockBaseClaim < Claim::BaseClaim
  def provider_delegator
    provider
  end

  delegate :provider, to: :creator

  def creator
    ExternalUser.new
  end

  SUBMISSION_STAGES = [
    {
      name: :step1,
      transitions: [
        { to_stage: :step2 }
      ]
    },
    { name: :step2 }
  ].freeze
end

class MockSteppableClaim < Claim::BaseClaim
  SUBMISSION_STAGES = [
    {
      name: :step1,
      transitions: [
        { to_stage: :step2 }
      ]
    },
    {
      name: :step2,
      transitions: [
        {
          to_stage: :step3A,
          condition: ->(claim) { claim.fixed_fee_case? }
        },
        {
          to_stage: :step3B,
          condition: ->(claim) { !claim.fixed_fee_case? }
        }
      ]
    },
    { name: :step3A },
    { name: :step3B }
  ].freeze
end

RSpec.describe Claim::BaseClaim do
  include DatabaseHousekeeping

  include_context 'claim-types object helpers'

  describe 'instantiation' do
    let(:advocate) { create(:external_user, :advocate) }

    it 'raises BaseClaimAbstractClassError when instantiated' do
      expect do
        described_class.new(external_user: advocate, creator: advocate)
      end.to raise_error Claim::BaseClaimAbstractClassError,
                         'Claim::BaseClaim is an abstract class and cannot be instantiated'
    end
  end

  describe 'scheme scopes' do
    let!(:agfs_final_claim) { create(:advocate_claim) }
    let!(:agfs_interim_claim) { create(:advocate_interim_claim) }
    let!(:lgfs_final_claim) { create(:litigator_claim) }
    let!(:lgfs_interim_claim) { create(:interim_claim) }
    let!(:lgfs_transfer_claim) { create(:transfer_claim) }

    describe '.agfs' do
      subject { described_class.agfs }

      it 'returns advocate final and interim claims' do
        is_expected.to contain_exactly(agfs_final_claim, agfs_interim_claim)
      end
    end

    describe '.lgfs' do
      subject { described_class.lgfs }

      it 'returns litigator final, interim and transfer claims' do
        is_expected.to contain_exactly(lgfs_final_claim, lgfs_interim_claim, lgfs_transfer_claim)
      end
    end
  end

  describe 'claim type methods' do
    let(:agfs_claim) { create(:advocate_claim) }
    let(:lgfs_claim) { create(:litigator_claim) }

    describe '.claim_types' do
      specify do
        expect(described_class.claim_types.map(&:to_s)).to match_array(agfs_claim_object_types | lgfs_claim_object_types)
      end
    end

    describe '.agfs_claim_types' do
      specify { expect(described_class.agfs_claim_types.map(&:to_s)).to match_array(agfs_claim_object_types) }
    end

    describe '.lgfs_claim_types' do
      specify { expect(described_class.lgfs_claim_types.map(&:to_s)).to match_array(lgfs_claim_object_types) }
    end

    describe '#agfs?' do
      context 'when the claim is AGFS' do
        it { expect(agfs_claim.agfs?).to be true }
      end

      context 'when the claim is LGFS' do
        it { expect(lgfs_claim.agfs?).to be false }
      end
    end

    describe '#lgfs?' do
      context 'when the claim is AGFS' do
        it { expect(agfs_claim.lgfs?).to be false }
      end

      context 'when the claim is LGFS' do
        it { expect(lgfs_claim.lgfs?).to be true }
      end
    end

    describe '.agfs?' do
      context 'when the claim is AGFS' do
        it { expect(agfs_claim.class.agfs?).to be true }
      end

      context 'when the claim is LGFS' do
        it { expect(lgfs_claim.class.agfs?).to be false }
      end
    end

    describe '.lgfs?' do
      context 'when the claim is AGFS' do
        it { expect(agfs_claim.class.lgfs?).to be false }
      end

      context 'when the claim is LGFS' do
        it { expect(lgfs_claim.class.lgfs?).to be true }
      end
    end
  end

  describe 'has_many documents association' do
    it 'returns a collection of verified documents only' do
      claim = create(:claim)
      verified_doc1 = create(:document, :verified, claim:)
      _unverified_doc1 = create(:document, :unverified, claim:)
      _unverified_doc2 = create(:document, :unverified, claim:)
      verified_doc2 = create(:document, :verified, claim:)
      claim.reload
      expect(claim.documents.map(&:id)).to contain_exactly(verified_doc1.id, verified_doc2.id)
    end
  end

  describe 'expenses' do
    let!(:claim) { create(:litigator_claim) }
    let!(:expense_with_vat) { create(:expense, claim:, amount: 100.0, vat_amount: 20) }
    let!(:another_expense_with_vat) { create(:expense, claim:, amount: 50.50, vat_amount: 10.10) }
    let!(:expense_without_vat) { create(:expense, claim:, amount: 100.0, vat_amount: 0.0) }
    let!(:another_expense_without_vat) { create(:expense, claim:, amount: 25.0, vat_amount: 0.0) }

    describe '#expenses.with_vat' do
      it 'returns an array of expenses with VAT' do
        expect(claim.expenses.with_vat).to contain_exactly(expense_with_vat, another_expense_with_vat)
      end
    end

    describe '#expenses.without_vat' do
      it 'returns an array of expenses without VAT' do
        expect(claim.expenses.without_vat).to contain_exactly(expense_without_vat, another_expense_without_vat)
      end
    end

    describe '#expenses_with_vat_total' do
      it 'return the sum of the amounts for the expenses with vat' do
        expect(claim.expenses_with_vat_net).to eq 150.50
      end
    end

    describe '#expenses_without_vat_total' do
      it 'return the sum of the amounts for the expenses without vat' do
        expect(claim.expenses_without_vat_net).to eq 125.0
      end
    end
  end

  describe '#applicable_for_written_reasons?' do
    subject(:applicable_for_written_reasons?) { claim.applicable_for_written_reasons? }

    context 'when the claim is a Hardship claim' do
      let(:claim) { create(:litigator_hardship_claim, :redetermination) }

      it { is_expected.to be false }
    end

    context 'when the claim is not a Hardship claim' do
      let(:claim) { create(:deterministic_claim, :redetermination) }

      it { is_expected.to be true }
    end
  end

  describe 'disbursements' do
    let!(:claim) { create(:litigator_claim) }
    let!(:disbursement_with_vat) { create(:disbursement, claim:, net_amount: 100.0, vat_amount: 20) }
    let!(:another_disbursement_with_vat) { create(:disbursement, claim:, net_amount: 50.50, vat_amount: 10.10) }
    let!(:disbursement_without_vat) { create(:disbursement, claim:, net_amount: 100.0, vat_amount: 0.0) }
    let!(:another_disbursement_without_vat) { create(:disbursement, claim:, net_amount: 25.0, vat_amount: 0.0) }

    describe '#disbursements.with_vat' do
      subject { claim.disbursements.with_vat }

      it { is_expected.to contain_exactly(disbursement_with_vat, another_disbursement_with_vat) }
    end

    describe '#disbursements.without_vat' do
      subject { claim.disbursements.without_vat }

      it { is_expected.to contain_exactly(disbursement_without_vat, another_disbursement_without_vat) }
    end

    describe '#disbursements_with_vat_net' do
      subject { claim.disbursements_with_vat_net }

      it { is_expected.to eq 150.50 }
    end

    describe '#disbursements_without_vat_net' do
      subject { claim.disbursements_without_vat_net }

      it { is_expected.to eq 125.0 }
    end
  end

  describe '#assessment' do
    subject(:assessment) { claim.assessment }

    context 'when claim built' do
      let(:claim) { build(:advocate_claim) }

      it { expect(claim).not_to be_persisted }
      it { expect(assessment).not_to be_nil }
      it { expect(assessment).not_to be_persisted }
      it { expect(assessment).to have_attributes(fees: 0.0, expenses: 0.0, disbursements: 0.0) }
    end

    context 'when claim created' do
      let(:claim) { create(:advocate_claim) }

      it { expect(claim).to be_persisted }
      it { expect(assessment).not_to be_nil }
      it { expect(assessment).to be_persisted }
      it { expect(assessment).to have_attributes(fees: 0.0, expenses: 0.0, disbursements: 0.0) }
    end
  end

  describe '#fixed_fee_case?' do
    subject { claim.fixed_fee_case? }

    context 'when the case type does not exist' do
      let(:claim) { MockBaseClaim.new }

      specify { is_expected.to be_nil }
    end

    context 'when the case type is set' do
      let(:case_type) { build(:case_type) }
      let(:claim) { MockBaseClaim.new(case_type:) }

      context 'when there is no fixed fee' do
        let(:case_type) { build(:case_type, is_fixed_fee: false) }

        specify { is_expected.to be(false) }
      end

      context 'when there is a fixed fee' do
        let(:case_type) { build(:case_type, is_fixed_fee: true) }

        specify { is_expected.to be(true) }
      end
    end
  end

  describe '#next_step' do
    let(:claim) { MockSteppableClaim.new }
    let(:step) { :step1 }

    context 'when the claim is for a fixed fee' do
      before do
        allow(claim).to receive(:fixed_fee_case?).and_return(true)
        claim.form_step = step
      end

      it 'does not change the current step' do
        expect { claim.next_step }
          .not_to change(claim, :current_step)
          .from(step)
      end

      context 'when at step 1' do
        it { expect(claim.next_step).to eq(:step2) }
      end

      context 'when at step 2' do
        let(:step) { :step2 }

        it { expect(claim.next_step).to eq(:step3A) }
      end

      context 'when at step 3A' do
        let(:step) { :step3A }

        it { expect(claim.next_step).to be_nil }
      end
    end

    context 'when the claim is not for a fixed fee' do
      before do
        allow(claim).to receive(:fixed_fee_case?).and_return(false)
        claim.form_step = step
      end

      it 'does not change the current step' do
        expect { claim.next_step }
          .not_to change(claim, :current_step)
          .from(step)
      end

      context 'when at step 1' do
        it { expect(claim.next_step).to eq(:step2) }
      end

      context 'when at step 2' do
        let(:step) { :step2 }

        it { expect(claim.next_step).to eq(:step3B) }
      end

      context 'when at step 3B' do
        let(:step) { :step3B }

        it { expect(claim.next_step).to be_nil }
      end
    end
  end

  describe '#next_step!' do
    let(:step) { :step1 }
    let(:claim) { MockSteppableClaim.new }

    context 'when the claim is for a fixed fee' do
      before do
        allow(claim).to receive(:fixed_fee_case?).and_return(true)
        claim.form_step = step
      end

      context 'when at step 1' do
        it { expect(claim.next_step!).to eq(:step2) }
      end

      context 'when at step 2' do
        let(:step) { :step2 }

        it { expect(claim.next_step!).to eq(:step3A) }
      end

      context 'when at step 3A' do
        let(:step) { :step3A }

        it { expect(claim.next_step!).to be_nil }
      end
    end

    context 'when the claim is not for a fixed fee' do
      before do
        allow(claim).to receive(:fixed_fee_case?).and_return(false)
        claim.form_step = step
      end

      context 'when at step 1' do
        it { expect(claim.next_step!).to eq(:step2) }
      end

      context 'when at step 2' do
        let(:step) { :step2 }

        it { expect(claim.next_step!).to eq(:step3B) }
      end

      context 'when at step 3B' do
        let(:step) { :step3B }

        it { expect(claim.next_step!).to be_nil }
      end
    end
  end

  describe '#next_step?' do
    let(:claim) { MockSteppableClaim.new }

    context 'when there is a next step to go to' do
      let(:step) { :step1 }

      before do
        claim.form_step = step
      end

      specify { expect(claim.next_step?).to be_truthy }
    end

    context 'when there is NOT a next step to go to' do
      let(:step) { :step3A }

      before do
        claim.form_step = step
      end

      specify { expect(claim.next_step?).to be_falsey }
    end
  end

  describe '#previous_step' do
    let(:claim) { MockSteppableClaim.new }

    context 'when the claim is for a fixed fee' do
      let(:step) { :step3A }

      before do
        allow(claim).to receive(:fixed_fee_case?).and_return(true)
        claim.form_step = step
      end

      it 'does not change the current step' do
        expect { claim.previous_step }
          .not_to change(claim, :current_step)
          .from(step)
      end

      context 'when at step 3A' do
        it { expect(claim.previous_step).to eq(:step2) }
      end

      context 'when at step 2' do
        let(:step) { :step2 }

        it { expect(claim.previous_step).to eq(:step1) }
      end

      context 'when at step 1' do
        let(:step) { :step1 }

        it { expect(claim.previous_step).to be_nil }
      end
    end

    context 'when the claim is not for a fixed fee' do
      let(:step) { :step3B }

      before do
        allow(claim).to receive(:fixed_fee_case?).and_return(false)
        claim.form_step = step
      end

      it 'does not change the current step' do
        expect { claim.previous_step }
          .not_to change(claim, :current_step)
          .from(step)
      end

      context 'when at step 3B' do
        it { expect(claim.previous_step).to eq(:step2) }
      end

      context 'when at step 2' do
        let(:step) { :step2 }

        it { expect(claim.previous_step).to eq(:step1) }
      end

      context 'when at step 1' do
        let(:step) { :step1 }

        it { expect(claim.previous_step).to be_nil }
      end
    end
  end

  describe '#step_back?' do
    let(:claim) { MockSteppableClaim.new }

    context 'when there is a previous step to go to' do
      let(:step) { :step2 }

      before do
        claim.form_step = step
      end

      specify { expect(claim.step_back?).to be_truthy }
    end

    context 'when there is NOT a previous step to go to' do
      let(:step) { :step1 }

      before do
        claim.form_step = step
      end

      specify { expect(claim.step_back?).to be_falsey }
    end
  end

  describe '#step_validation_required?' do
    let(:claim) { MockSteppableClaim.new(source:) }

    context 'when the claim is from an API submission' do
      let(:source) { 'api' }

      specify { expect(claim.step_validation_required?(:some_step)).to be_truthy }
    end

    context 'when the claim is not from an API submission' do
      let(:source) { 'web' }

      context 'when the form step is nil' do
        before do
          claim.form_step = nil
        end

        specify { expect(claim.step_validation_required?(:some_step)).to be_truthy }
      end

      context 'when the form step is set' do
        before do
          claim.form_step = :some_step
        end

        context 'when it matches the provided step' do
          specify { expect(claim.step_validation_required?(:some_step)).to be_truthy }
        end

        context 'when it does not match the provided step' do
          specify { expect(claim.step_validation_required?(:other_step)).to be_falsey }
        end
      end
    end
  end

  describe '#trial_length' do
    subject(:trial_length) { claim.trial_length }

    let(:actual_trial_length) { 3 }
    let(:retrial_actual_length) { 5 }
    let(:claim) { MockSteppableClaim.new(actual_trial_length:, retrial_actual_length:) }

    context 'when the claim requires re-trial dates' do
      before do
        expect(claim).to receive(:requires_retrial_dates?).and_return(true)
      end

      specify { is_expected.to eq(retrial_actual_length) }
    end

    context 'when the claim requires trial dates' do
      before do
        expect(claim).to receive(:requires_retrial_dates?).and_return(false)
        expect(claim).to receive(:requires_trial_dates?).and_return(true)
      end

      specify { is_expected.to eq(actual_trial_length) }
    end

    context 'when the claim does not require trial dates or re-trial dates' do
      before do
        expect(claim).to receive(:requires_retrial_dates?).and_return(false)
        expect(claim).to receive(:requires_trial_dates?).and_return(false)
      end

      specify { is_expected.to be_nil }
    end
  end

  describe '#unread_messages_for' do
    subject(:call) { claim.unread_messages_for(user) }

    let(:claim) { create(:submitted_claim) }
    let(:user) { claim.external_user.user }

    context 'with no messages' do
      it 'returns an empty array' do
        is_expected.to eq([])
      end
    end

    context 'with a single message' do
      let!(:message) { create(:message, claim:) }

      it 'returns the message before it is read' do
        is_expected.to include message
      end

      it 'does not return a message after it is read' do
        message.user_message_statuses.where(user:).update(read: true)

        expect(call).not_to include message
      end
    end

    context 'with multiple messages' do
      let!(:unread_messages) { create_list(:message, 2, claim:) }
      let(:read_messages) { create_list(:message, 2, claim:) }

      before { read_messages.each { |message| message.user_message_statuses.where(user:).update(read: true) } }

      it 'only shows messages not read by the user' do
        is_expected.to match_array(unread_messages)
      end
    end
  end
end

RSpec.describe MockBaseClaim do
  it_behaves_like 'a base claim'
  it_behaves_like 'uses claim cleaner', Cleaners::NullClaimCleaner do
    let(:mock_claim_creator) do
      instance_double(ExternalUser, provider: instance_double(Provider, vat_registered?: false))
    end

    before { allow(ExternalUser).to receive(:new).and_return(mock_claim_creator) }
  end

  describe 'date formatting' do
    it 'accepts a variety of formats and populate the date accordingly' do
      def make_date_params(date_string)
        day, month, year = date_string.split('-')
        {
          'first_day_of_trial(3i)' => day,
          'first_day_of_trial(2i)' => month,
          'first_day_of_trial(1i)' => year
        }
      end

      dates = {
        '04-10-80' => Date.new(80, 10, 4),
        '04-10-1980' => Date.new(1980, 10, 4),
        '04-1-1980' => Date.new(1980, 1, 4),
        '4-1-1980' => Date.new(1980, 1, 4),
        '4-10-1980' => Date.new(1980, 10, 4),
        '04-10-10' => Date.new(10, 10, 4),
        '04-10-2010' => Date.new(2010, 10, 4),
        '04-1-2010' => Date.new(2010, 1, 4),
        '4-1-2010' => Date.new(2010, 1, 4),
        '4-10-2010' => Date.new(2010, 10, 4)
      }
      dates.each do |date_string, date|
        params = make_date_params(date_string)
        claim = MockBaseClaim.new(params)
        expect(claim.first_day_of_trial).to eq date
      end
    end
  end

  describe '#disk_evidence_reference' do
    context 'when case number is not set' do
      let(:claim) { described_class.new(case_number: nil) }

      specify { expect(claim.disk_evidence_reference).to be_nil }
    end

    context 'when claim id is not set' do
      let(:claim) { described_class.new(case_number: 'A20161234', id: nil) }

      specify { expect(claim.disk_evidence_reference).to be_nil }
    end

    context 'when case number and claim id are set' do
      let(:claim) { described_class.new(case_number: 'A20161234', id: 9999) }

      specify { expect(claim.disk_evidence_reference).to eq('A20161234/9999') }
    end
  end

  describe '#evidence_doc_types' do
    let(:claim) { described_class.new(evidence_checklist_ids: [1, 5, 10]) }

    it { expect(claim.evidence_doc_types.map(&:class)).to eq([DocType, DocType, DocType]) }

    it do
      expect(claim.evidence_doc_types.map(&:name)).to contain_exactly('Representation order',
                                                                      'Order in respect of judicial apportionment',
                                                                      'Special preparation form')
    end
  end

  describe '#remote?' do
    it 'returns false' do
      claim = described_class.new
      expect(claim.remote?).to be false
    end
  end

  describe '#eligible_document_types' do
    let(:claim) { described_class.new }
    let(:mock_doc_types) { instance_double(DocType) }

    before { allow(Claims::FetchEligibleDocumentTypes).to receive(:for).with(claim).and_return(mock_doc_types) }

    it { expect(claim.eligible_document_types).to eq(mock_doc_types) }
  end

  describe '#discontinuance?' do
    subject { claim.discontinuance? }

    let(:claim) { described_class.new(case_type:) }

    context 'when case type nil' do
      let(:case_type) { nil }

      it { is_expected.to be_falsey }
    end

    context 'when case type not a discontinuance' do
      let(:case_type) { build(:case_type, :trial) }

      it { is_expected.to be_falsey }
    end

    context 'when case type is a discontinuance' do
      let(:case_type) { build(:case_type, :discontinuance) }

      it { is_expected.to be_truthy }
    end
  end

  describe '#agfs_reform?' do
    let(:claim) { described_class.new }

    specify { expect(claim).to delegate_method(:agfs_reform?).to(:fee_scheme) }
  end

  describe '#agfs_scheme_12?' do
    let(:claim) { described_class.new }

    specify { expect(claim).to delegate_method(:agfs_scheme_12?).to(:fee_scheme) }
  end

  describe '#earliest_representation_order' do
    subject(:earliest_representation_order) { claim.earliest_representation_order }

    let(:claim) { described_class.new }

    context 'when there are no defendants' do
      before do
        claim.defendants = []
      end

      specify { expect(earliest_representation_order).to be_nil }
    end

    context 'when there are no earliest representation orders for the defendants' do
      let(:defendants) { build_list(:defendant, 2) }

      before do
        claim.defendants = defendants

        defendants.each do |defendant|
          allow(defendant).to receive(:earliest_representation_order).and_return(nil)
        end
      end

      it { expect(earliest_representation_order).to be_nil }
    end

    context 'when some of the defendants have an earliest representation order set' do
      let(:base_date) { 3.months.ago.to_date }
      let(:expected_representation_order) do
        build(:representation_order, representation_order_date: base_date - 2.days)
      end
      let(:later_representation_order) do
        build(:representation_order, representation_order_date: base_date + 3.days)
      end
      let(:defendant_with_earliest_representation_date) { build(:defendant) }
      let(:defendant_with_later_representation_date) { build(:defendant) }
      let(:defendant_with_no_earliest_representation_date) { build(:defendant) }
      let(:defendants) do
        [
          defendant_with_later_representation_date,
          defendant_with_earliest_representation_date,
          defendant_with_no_earliest_representation_date
        ]
      end

      before do
        allow(defendant_with_no_earliest_representation_date).to receive(
          :earliest_representation_order
        ).and_return(nil)
        allow(defendant_with_later_representation_date).to receive(
          :earliest_representation_order
        ).and_return(later_representation_order)
        allow(defendant_with_earliest_representation_date).to receive(
          :earliest_representation_order
        ).and_return(expected_representation_order)
        claim.defendants = defendants
      end

      it 'returns the earliest representation order out of all the defendants' do
        expect(earliest_representation_order).to eq(expected_representation_order)
      end
    end
  end

  describe '#vat_registered?' do
    subject(:registered) { claim.vat_registered? }

    let(:claim) { described_class.new }

    before do
      allow(claim).to receive(:provider_delegator).and_return(provider_delegator)
      allow(LogStuff).to receive(:error)
    end

    context 'when the provider exists' do
      let(:provider_delegator) { double(:provider_delegator, vat_registered?: true) }

      it 'does not log error' do
        registered
        expect(LogStuff).not_to have_received(:error)
      end
    end

    # Can happen for a chambers provider with more than one external_user
    # and creator does not select an external_user on case_details page
    # for a "final" claim case_type (e.g. Trial)
    context 'when the provider_delegator is nil' do
      let(:provider_delegator) { nil }

      it 'logs error' do
        registered
        expect(LogStuff).to have_received(:error).once
      end

      it 'does not raise error' do
        expect { registered }.not_to raise_error
      end
    end
  end
end

describe '#earliest_representation_order_date' do
  let(:april_1st) { Date.new(2016, 4, 1) }
  let(:march_10th) { Date.new(2016, 3, 10) }
  let(:jun_30th) { Date.new(2016, 6, 30) }
  let(:claim) { create(:claim) }

  before do
    claim.defendants.clear
    claim.save
    claim.reload
  end

  context 'when there are no rep orders' do
    it { expect(claim.representation_orders).to be_empty }
    it { expect(claim.earliest_representation_order_date).to be_nil }
  end

  context 'when there is one rep order' do
    let!(:first_defendant) { create(:defendant, :without_reporder, claim:) }
    let!(:first_rep_order) do
      create(:representation_order, defendant: first_defendant, representation_order_date: april_1st)
    end

    it { expect(claim.representation_orders.size).to eq 1 }
    it { expect(claim.earliest_representation_order_date).to eq april_1st }
  end

  context 'when there is a defendant with multiple rep orders' do
    let!(:first_defendant) { create(:defendant, :without_reporder, claim:) }
    let!(:first_rep_order) do
      create(:representation_order, defendant: first_defendant, representation_order_date: april_1st)
    end
    let!(:second_rep_order) do
      create(:representation_order, defendant: first_defendant, representation_order_date: jun_30th)
    end

    it { expect(claim.representation_orders.size).to eq 2 }
    it { expect(claim.earliest_representation_order_date).to eq april_1st }
  end

  context 'when there are multiple defendants' do
    let!(:first_defendant) { create(:defendant, :without_reporder, claim:) }
    let!(:second_defendant) { create(:defendant, :without_reporder, claim:) }
    let!(:first_rep_order) do
      create(:representation_order, defendant: first_defendant, representation_order_date: april_1st)
    end
    let!(:second_rep_order) do
      create(:representation_order, defendant: second_defendant, representation_order_date: march_10th)
    end

    it { expect(claim.representation_orders.size).to eq 2 }
    it { expect(claim.earliest_representation_order_date).to eq march_10th }
  end
end
