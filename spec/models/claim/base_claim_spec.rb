require 'rails_helper'
require 'support/shared_examples_for_claim_types'

class MockBaseClaim < Claim::BaseClaim
  def provider_delegator
    provider
  end

  def provider
    creator.provider
  end

  def creator
    ExternalUser.new
  end

  SUBMISSION_STAGES = [
    {
      name: :step_1,
      transitions: [
        { to_stage: :step_2 }
      ]
    },
    { name: :step_2 }
  ].freeze
end

class MockSteppableClaim < Claim::BaseClaim
  SUBMISSION_STAGES = [
    {
      name: :step_1,
      transitions: [
        { to_stage: :step_2 }
      ]
    },
    {
      name: :step_2,
      transitions: [
        {
          to_stage: :step_3A,
          condition: ->(claim) { claim.fixed_fee_case? }
        },
        {
          to_stage: :step_3B,
          condition: ->(claim) { !claim.fixed_fee_case? }
        }
      ]
    },
    { name: :step_3A },
    { name: :step_3B }
  ].freeze
end

RSpec.describe Claim::BaseClaim do
  include DatabaseHousekeeping

  let(:advocate) { create :external_user, :advocate }
  let(:agfs_claim) { create(:advocate_claim) }
  let(:lgfs_claim) { create(:litigator_claim) }

  include_context 'claim-types object helpers'

  it 'raises BaseClaimAbstractClassError when instantiated' do
    expect {
      described_class.new(external_user: advocate, creator: advocate)
    }.to raise_error ::Claim::BaseClaimAbstractClassError, 'Claim::BaseClaim is an abstract class and cannot be instantiated'
  end

  context 'scheme scopes' do
    let!(:agfs_final_claim) { create(:advocate_claim) }
    let!(:agfs_interim_claim) { create(:advocate_interim_claim) }
    let!(:lgfs_final_claim) { create(:litigator_claim) }
    let!(:lgfs_interim_claim) { create(:interim_claim) }
    let!(:lgfs_transfer_claim) { create(:transfer_claim) }

    describe '.agfs' do
      subject { described_class.agfs }

      it 'returns advocate final and interim claims' do
        is_expected.to match_array [agfs_final_claim, agfs_interim_claim]
      end
    end

    describe '.lgfs' do
      subject { described_class.lgfs }

      it 'returns litigator final, interim and transfer claims' do
        is_expected.to match_array [lgfs_final_claim, lgfs_interim_claim, lgfs_transfer_claim]
      end
    end
  end

  describe '.agfs_claim_types' do
    specify { expect(described_class.agfs_claim_types.map(&:to_s)).to match_array(agfs_claim_object_types) }
  end

  describe '.lgfs_claim_types' do
    specify { expect(described_class.lgfs_claim_types.map(&:to_s)).to match_array(lgfs_claim_object_types) }
  end

  describe '#agfs?' do
    it 'returns true if claim is advocate/agfs claim, false for litigator/lgfs claims' do
      expect(agfs_claim.agfs?).to eql true
      expect(lgfs_claim.agfs?).to eql false
    end
  end

  describe '#lgfs?' do
    it 'returns true if claim is litigator/lgfs claim, false for advocate/agfs claims' do
      expect(lgfs_claim.lgfs?).to eql true
      expect(agfs_claim.lgfs?).to eql false
    end
  end

  describe '.agfs?' do
    it 'returns true if class is advocate claim, false otherwise' do
      expect(agfs_claim.class.agfs?).to eql true
      expect(lgfs_claim.class.agfs?).to eql false
    end
  end

  describe '.lgfs?' do
    it 'returns true if claim is litigator/lgfs claim, false for advocate/agfs claims' do
      expect(lgfs_claim.class.lgfs?).to eql true
      expect(agfs_claim.class.lgfs?).to eql false
    end
  end

  describe 'has_many documents association' do
    it 'should return a collection of verified documents only' do
      claim = create :claim
      verified_doc_1 = create :document, :verified, claim: claim
      _unverified_doc_1 = create :document, :unverified, claim: claim
      _unverified_doc_2 = create :document, :unverified, claim: claim
      verified_doc_2 = create :document, :verified, claim: claim
      claim.reload
      expect(claim.documents.map(&:id)).to match_array([verified_doc_1.id, verified_doc_2.id])
    end
  end

  context 'expenses' do
    before(:all) do
      @claim = create :litigator_claim
      @ex1 = create :expense, claim: @claim, amount: 100.0, vat_amount: 20
      @ex2 = create :expense, claim: @claim, amount: 100.0, vat_amount: 0.0
      @ex3 = create :expense, claim: @claim, amount: 50.50, vat_amount: 10.10
      @ex4 = create :expense, claim: @claim, amount: 25.0, vat_amount: 0.0
      @claim.reload
    end

    after(:all) { clean_database }

    describe '#expenses.with_vat' do
      it 'returns an array of expenses with VAT' do
        expect(@claim.expenses.with_vat).to match_array([@ex1, @ex3])
      end
    end

    describe '#expenses.without_vat' do
      it 'returns an array of expenses without VAT' do
        expect(@claim.expenses.without_vat).to match_array([@ex2, @ex4])
      end
    end

    describe '#expenses_with_vat_total' do
      it 'return the sum of the amounts for the expenses with vat' do
        expect(@claim.expenses_with_vat_net). to eq 150.50
      end
    end

    describe '#expenses_without_vat_total' do
      it 'return the sum of the amounts for the expenses without vat' do
        expect(@claim.expenses_without_vat_net). to eq 125.0
      end
    end
  end

  describe '.applicable_for_written_reasons?' do
    subject(:applicable_for_written_reasons?) { claim.applicable_for_written_reasons? }

    context 'when the claim is a Hardship claim' do
      let(:claim) { create :litigator_hardship_claim, :redetermination }

      it { is_expected.to be false }
    end

    context 'when the claim is not a Hardship claim' do
      let(:claim) { create :deterministic_claim, :redetermination }

      it { is_expected.to be true }
    end
  end

  context 'disbursements' do
    before(:all) do
      @claim = create :litigator_claim
      @db1 = create :disbursement, claim: @claim, net_amount: 100.0, vat_amount: 20
      @db2 = create :disbursement, claim: @claim, net_amount: 100.0, vat_amount: 0.0
      @db3 = create :disbursement, claim: @claim, net_amount: 50.50, vat_amount: 10.10
      @db4 = create :disbursement, claim: @claim, net_amount: 25.0, vat_amount: 0.0
      @claim.reload
    end

    after(:all) { clean_database }

    describe '#disbursements.with_vat' do
      it 'returns an array of disbursements with VAT' do
        expect(@claim.disbursements.with_vat).to match_array([@db1, @db3])
      end
    end

    describe '#disbursements.without_vat' do
      it 'returns an array of disbursements without VAT' do
        expect(@claim.disbursements.without_vat).to match_array([@db2, @db4])
      end
    end

    describe '#disbursements' do
      it 'return the sum of the amounts for the disbursements with vat' do
        expect(@claim.disbursements_with_vat_net). to eq 150.50
      end
    end

    describe '#disbursements' do
      it 'return the sum of the amounts for the disbursements without vat' do
        expect(@claim.disbursements_without_vat_net). to eq 125.0
      end
    end
  end

  describe '#assessment' do
    subject { claim.assessment }

    context 'when claim built' do
      let(:claim) { build(:advocate_claim) }

      it 'builds a zeroized assessment' do
        expect(claim).to_not be_persisted
        is_expected.to_not be_nil
        is_expected.to_not be_persisted
        is_expected.to have_attributes(fees: 0.0, expenses: 0.0, disbursements: 0.0)
      end
    end

    context 'when claim created' do
      let(:claim) { create(:advocate_claim) }

      it 'creates an zeroized assessment' do
        expect(claim).to be_persisted
        is_expected.to_not be_nil
        is_expected.to be_persisted
        is_expected.to have_attributes(fees: 0.0, expenses: 0.0, disbursements: 0.0)
      end
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
      let(:claim) { MockBaseClaim.new(case_type: case_type) }

      context 'and does not have a fixed fee' do
        let(:case_type) { build(:case_type, is_fixed_fee: false) }

        specify { is_expected.to eq(false) }
      end

      context 'and has a fixed fee' do
        let(:case_type) { build(:case_type, is_fixed_fee: true) }

        specify { is_expected.to eq(true) }
      end
    end
  end

  describe '#next_step' do
    let(:claim) { MockSteppableClaim.new }
    let(:step) { :step_1 }

    context 'when condition 3A is met' do
      before do
        allow(claim).to receive(:fixed_fee_case?).and_return(true)
        claim.form_step = step
      end

      it 'does not change the current step' do
        expect { claim.next_step }
          .not_to change { claim.current_step }
          .from(step)
      end

      it 'follows the steps path 1 -> 2 -> 3A' do
        expect(claim.next_step).to eq(:step_2)
        claim.form_step = claim.next_step
        expect(claim.next_step).to eq(:step_3A)
        claim.form_step = claim.next_step
        expect(claim.next_step).to eq(nil)
      end
    end

    context 'when condition 3B is met' do
      before do
        allow(claim).to receive(:fixed_fee_case?).and_return(false)
        claim.form_step = step
      end

      it 'does not change the current step' do
        expect { claim.next_step }
          .not_to change { claim.current_step }
          .from(step)
      end

      it 'follows the steps path 1 -> 2 -> 3B' do
        expect(claim.next_step).to eq(:step_2)
        claim.form_step = claim.next_step
        expect(claim.next_step).to eq(:step_3B)
        claim.form_step = claim.next_step
        expect(claim.next_step).to eq(nil)
      end
    end
  end

  describe '#next_step!' do
    let(:claim) { MockSteppableClaim.new(form_step: :step_1) }

    context 'when condition 3A is met' do
      before do
        allow(claim).to receive(:fixed_fee_case?).and_return(true)
      end

      it 'follows the steps path 1 -> 2 -> 3A' do
        expect(claim.next_step!).to eq(:step_2)
        expect(claim.next_step!).to eq(:step_3A)
        expect(claim.next_step!).to eq(nil)
      end
    end

    context 'when condition 3B is met' do
      before do
        allow(claim).to receive(:fixed_fee_case?).and_return(false)
      end

      it 'follows the steps path 1 -> 2 -> 3B' do
        expect(claim.next_step!).to eq(:step_2)
        expect(claim.next_step!).to eq(:step_3B)
        expect(claim.next_step!).to eq(nil)
      end
    end
  end

  describe '#next_step?' do
    let(:claim) { MockSteppableClaim.new }

    context 'when there is a next step to go to' do
      let(:step) { :step_1 }

      before do
        claim.form_step = step
      end

      specify { expect(claim.next_step?).to be_truthy }
    end

    context 'when there is NOT a next step to go to' do
      let(:step) { :step_3A }

      before do
        claim.form_step = step
      end

      specify { expect(claim.next_step?).to be_falsey }
    end
  end

  describe '#previous_step' do
    let(:claim) { MockSteppableClaim.new }

    context 'when condition 3A was met' do
      let(:step) { :step_3A }

      before do
        allow(claim).to receive(:fixed_fee_case?).and_return(true)
        claim.form_step = step
      end

      it 'does not change the current step' do
        expect { claim.previous_step }
          .not_to change { claim.current_step }
          .from(step)
      end

      it 'follows the steps path 3A -> 2 -> 1' do
        expect(claim.previous_step).to eq(:step_2)
        claim.form_step = claim.previous_step
        expect(claim.previous_step).to eq(:step_1)
        claim.form_step = claim.previous_step
        expect(claim.previous_step).to eq(nil)
      end
    end

    context 'when condition 3B was met' do
      let(:step) { :step_3B }

      before do
        allow(claim).to receive(:fixed_fee_case?).and_return(false)
        claim.form_step = step
      end

      it 'does not change the current step' do
        expect { claim.previous_step }
          .not_to change { claim.current_step }
          .from(step)
      end

      it 'follows the steps path 3B -> 2 -> 1' do
        expect(claim.previous_step).to eq(:step_2)
        claim.form_step = claim.previous_step
        expect(claim.previous_step).to eq(:step_1)
        claim.form_step = claim.previous_step
        expect(claim.previous_step).to eq(nil)
      end
    end
  end

  describe '#step_back?' do
    let(:claim) { MockSteppableClaim.new }

    context 'when there is a previous step to go to' do
      let(:step) { :step_2 }

      before do
        claim.form_step = step
      end

      specify { expect(claim.step_back?).to be_truthy }
    end

    context 'when there is NOT a previous step to go to' do
      let(:step) { :step_1 }

      before do
        claim.form_step = step
      end

      specify { expect(claim.step_back?).to be_falsey }
    end
  end

  describe '#step_validation_required?' do
    let(:claim) { MockSteppableClaim.new(source: source) }

    context 'when the claim is from an API submission' do
      let(:source) { 'api' }

      specify { expect(claim.step_validation_required?(:some_step)).to be_truthy }
    end

    context 'when the claim is not from an API submission' do
      let(:source) { 'web' }

      context 'and the form step is nil' do
        before do
          claim.form_step = nil
        end

        specify { expect(claim.step_validation_required?(:some_step)).to be_truthy }
      end

      context 'and the form step is set' do
        before do
          claim.form_step = :some_step
        end

        context 'and it matches the provided step' do
          specify { expect(claim.step_validation_required?(:some_step)).to be_truthy }
        end

        context 'but it does not match the provided step' do
          specify { expect(claim.step_validation_required?(:other_step)).to be_falsey }
        end
      end
    end
  end

  describe '#trial_length' do
    subject(:trial_length) { claim.trial_length }

    let(:actual_trial_length) { 3 }
    let(:retrial_actual_length) { 5 }
    let(:claim) { MockSteppableClaim.new(actual_trial_length: actual_trial_length, retrial_actual_length: retrial_actual_length) }

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
      let!(:message) { create(:message, claim: claim) }

      it 'returns the message before it is read' do
        is_expected.to include message
      end

      it 'does not return a message after it is read' do
        message.user_message_statuses.where(user: user).update(read: true)

        is_expected.not_to include message
      end
    end

    context 'with multiple messages' do
      let!(:message1) { create(:message, claim: claim) }
      let!(:message2) { create(:message, claim: claim) }
      let!(:message3) { create(:message, claim: claim) }
      let!(:message4) { create(:message, claim: claim) }

      before do
        message2.user_message_statuses.where(user: user).update(read: true)
        message3.user_message_statuses.where(user: user).update(read: true)
      end

      it 'only shows messages not read by the user' do
        is_expected.to match_array([message1, message4])
      end
    end
  end
end

RSpec.describe MockBaseClaim do
  it_behaves_like 'a base claim'

  context 'date formatting' do
    it 'should accept a variety of formats and populate the date accordingly' do
      def make_date_params(date_string)
        day, month, year = date_string.split('-')
        {
          'first_day_of_trial_dd' => day,
          'first_day_of_trial_mm' => month,
          'first_day_of_trial_yyyy' => year
        }
      end

      dates = {
       '04-10-80' => Date.new(80, 10, 04),
       '04-10-1980' => Date.new(1980, 10, 04),
       '04-1-1980' => Date.new(1980, 01, 04),
       '4-1-1980' => Date.new(1980, 01, 04),
       '4-10-1980' => Date.new(1980, 10, 04),
       '4-Oct-1980' => Date.new(1980, 10, 04),
       '04-Oct-1980' => Date.new(1980, 10, 04),
       '04-10-10' => Date.new(10, 10, 04),
       '04-10-2010' => Date.new(2010, 10, 04),
       '04-1-2010' => Date.new(2010, 01, 04),
       '4-1-2010' => Date.new(2010, 01, 04),
       '4-10-2010' => Date.new(2010, 10, 04),
       '4-Oct-2010' => Date.new(2010, 10, 04),
       '04-Oct-2010' => Date.new(2010, 10, 04),
       '04-nov-2001' => Date.new(2001, 11, 04),
       '4-jAn-1999' => Date.new(1999, 01, 04)
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
    it 'returns an array of DocType objects' do
      claim = described_class.new(evidence_checklist_ids: [1, 5, 10])
      expect(claim.evidence_doc_types.map(&:class)).to eq([DocType, DocType, DocType])
      expect(claim.evidence_doc_types.map(&:name)).to match_array(['Representation order', 'Order in respect of judicial apportionment', 'Special preparation form'])
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
    let(:mock_doc_types) { double(:doc_types) }

    specify {
      expect(Claims::FetchEligibleDocumentTypes).to receive(:for).with(claim).and_return(mock_doc_types)
      expect(claim.eligible_document_types).to eq(mock_doc_types)
    }
  end

  describe '#discontinuance?' do
    subject { claim.discontinuance? }

    let(:claim) { described_class.new }

    before { allow(claim).to receive(:case_type).and_return case_type }

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

  describe '#fee_scheme' do
    let(:claim) { described_class.new }
    let(:mock_fee_scheme) { instance_double(FeeScheme) }

    specify {
      expect(FeeScheme).to receive(:for_claim).with(claim).and_return(mock_fee_scheme)
      expect(claim.fee_scheme).to eq(mock_fee_scheme)
    }
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
      end

      specify {
        defendants.each do |defendant|
          expect(defendant).to receive(:earliest_representation_order).and_return(nil)
        end
        expect(earliest_representation_order).to be_nil
      }
    end

    context 'when some of the defendants have an earliest representation order set' do
      let(:base_date) { 3.months.ago.to_date }
      let(:expected_representation_order) {
        build(:representation_order, representation_order_date: base_date - 2.days)
      }
      let(:later_representation_order) {
        build(:representation_order, representation_order_date: base_date + 3.days)
      }
      let(:defendant_with_earliest_representation_date) { build(:defendant) }
      let(:defendant_with_later_representation_date) { build(:defendant) }
      let(:defendant_with_no_earliest_representation_date) { build(:defendant) }
      let(:defendants) {
        [
          defendant_with_later_representation_date,
          defendant_with_earliest_representation_date,
          defendant_with_no_earliest_representation_date
        ]
      }

      before do
        expect(defendant_with_no_earliest_representation_date).to receive(:earliest_representation_order).and_return(nil)
        expect(defendant_with_later_representation_date).to receive(:earliest_representation_order).and_return(later_representation_order)
        expect(defendant_with_earliest_representation_date).to receive(:earliest_representation_order).and_return(expected_representation_order)
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
    let(:mock_provider_delegator) { provider_delegator }

    before do
      allow(claim).to receive(:provider_delegator).and_return(mock_provider_delegator)
      allow(LogStuff).to receive(:error)
    end

    context 'when the provider exists' do
      let(:provider_delegator) { double(:provider_delegator, vat_registered?: true) }

      it 'does not log error' do
        registered
        expect(LogStuff).not_to have_received(:error)
      end
    end

    context 'when the provider is nil' do
      # this should never happen but the logger is implemented to trace errors in live
      let(:provider_delegator) { nil }

      it 'logs error' do
        expect { registered }.to raise_error NoMethodError # spy on, call and swallow error
        expect(LogStuff).to have_received(:error).once
      end

      it 'raises error' do
        expect { registered }.to raise_error NoMethodError
      end
    end
  end
end

# TODO: simplify get this working against a MockBaseClaim
describe '#earliest_representation_order_date' do
  let(:april_1) { Date.new(2016, 4, 1) }
  let(:march_10) { Date.new(2016, 3, 10) }
  let(:jun_30) { Date.new(2016, 6, 30) }
  let(:claim) { create :claim }

  before(:each) do
    claim.defendants.clear
    claim.save
  end

  it 'returns nil if there are no reporders' do
    expect(claim.representation_orders).to be_empty
    expect(claim.earliest_representation_order_date).to be nil
  end

  it 'returns the date of the only rep order' do
    defendant = create :defendant, :without_reporder, claim: claim
    create :representation_order, defendant: defendant, representation_order_date: april_1

    claim.reload
    expect(claim.representation_orders.size).to eq 1
    expect(claim.earliest_representation_order_date).to eq april_1
  end

  it 'returns the date of the earliest reporder across multiple defendants' do
    defendant_1 = create :defendant, :without_reporder, claim: claim
    create :representation_order, defendant: defendant_1, representation_order_date: april_1
    create :representation_order, defendant: defendant_1, representation_order_date: jun_30
    defendant_2 = create :defendant, :without_reporder, claim: claim
    create :representation_order, defendant: defendant_2, representation_order_date: march_10

    claim.reload
    expect(claim.representation_orders.size).to eq 3
    expect(claim.earliest_representation_order_date).to eq march_10
  end
end
