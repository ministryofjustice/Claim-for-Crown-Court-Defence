require 'rails_helper'
require_relative 'shared_examples_for_lgfs_claim'

describe Claim::TransferClaim, type: :model do
  subject(:claim) { build :transfer_claim, **options }

  let(:options) { {} }

  it_behaves_like 'uses claim cleaner', Cleaners::TransferClaimCleaner

  it { is_expected.not_to delegate_method(:requires_trial_dates?).to(:case_type) }
  it { is_expected.not_to delegate_method(:requires_retrial_dates?).to(:case_type) }

  context 'should delegate transfer detail attributes to transfer detail object' do
    it { is_expected.to delegate_method(:litigator_type).to(:transfer_detail) }
    it { is_expected.to delegate_method(:elected_case).to(:transfer_detail) }
    it { is_expected.to delegate_method(:transfer_stage_id).to(:transfer_detail) }
    it { is_expected.to delegate_method(:transfer_date).to(:transfer_detail) }
    it { is_expected.to delegate_method(:transfer_date_dd).to(:transfer_detail) }
    it { is_expected.to delegate_method(:transfer_date_mm).to(:transfer_detail) }
    it { is_expected.to delegate_method(:transfer_date_yyyy).to(:transfer_detail) }
    it { is_expected.to delegate_method(:case_conclusion_id).to(:transfer_detail) }
  end

  context 'transfer fee' do
    it 'creates a transfer fee when created in a factory' do
      claim = create :transfer_claim
      expect(claim.transfer_fee).to be_instance_of(Fee::TransferFee)
    end
  end

  describe '.new' do
    let(:today) { Date.today }

    it 'does not create a transfer detail if no params are passed to new' do
      claim = Claim::TransferClaim.new
      expect(claim.transfer_detail).to be_nil
    end

    it 'builds a transfer detail if one of the transfer detail attributes is mentioned in a .new' do
      claim = Claim::TransferClaim.new(elected_case: true)
      expect(claim.transfer_detail).not_to be_nil
      expect(claim.elected_case)
    end

    it 'builds a transfer detail on an existing claim when detail getter first used' do
      claim = Claim::TransferClaim.new
      expect(claim.transfer_detail).to be_nil
      claim.litigator_type
      expect(claim.transfer_detail).not_to be_nil
      expect(claim.transfer_detail).to be_unpopulated
    end

    it 'builds a transfer detail on an existing claim when detail setter first used' do
      claim = Claim::TransferClaim.new
      expect(claim.transfer_detail).to be_nil
      claim.litigator_type = 'original'
      expect(claim.transfer_detail).not_to be_nil
      expect(claim.transfer_detail.litigator_type).to eq 'original'
      expect(claim.litigator_type).to eq 'original'
    end

    it 'populates transfer detail with transfer detail attributes' do
      claim = Claim::TransferClaim.new(case_number: 'A20161234', litigator_type: 'new', elected_case: false, transfer_stage_id: 10, transfer_date: today, case_conclusion_id: 30)
      expect(claim.case_number).to eq 'A20161234'
      expect(claim.litigator_type).to eq 'new'
      expect(claim.elected_case).to be false
      expect(claim.transfer_stage_id).to eq 10
      expect(claim.transfer_date).to eq today
      expect(claim.case_conclusion_id).to eq 30

      detail = claim.transfer_detail
      expect(detail.litigator_type).to eq 'new'
      expect(detail.elected_case).to be false
      expect(detail.transfer_stage_id).to eq 10
      expect(detail.transfer_date).to eq today
      expect(detail.case_conclusion_id).to eq 30
    end
  end

  describe '#eligible_case_types' do
    it 'returns only Interim case types' do
      CaseType.delete_all

      c1 = create :case_type, name: 'AGFS case type', roles: ['agfs']
      c2 = create :case_type, name: 'LGFS case type', roles: ['lgfs']
      c3 = create :case_type, name: 'LGFS and Interim case type', roles: %w(lgfs interim)
      c4 = create :case_type, name: 'AGFS, LGFS and Interim case type', roles: %w(agfs lgfs interim)

      expect(claim.eligible_case_types).not_to include(c1)
      expect(claim.eligible_case_types).to include(c2)
      expect(claim.eligible_case_types).to include(c3)
      expect(claim.eligible_case_types).to include(c4)
    end
  end

  describe '#transfer?' do
    it 'returns true' do
      expect(claim.transfer?).to be true
    end
  end

  describe '#eligible_misc_fee_types' do
    subject(:call) { claim.eligible_misc_fee_types }

    let(:service) { instance_double(Claims::FetchEligibleMiscFeeTypes) }

    it 'calls eligible misc fee type fetch service' do
      expect(Claims::FetchEligibleMiscFeeTypes).to receive(:new).and_return service
      expect(service).to receive(:call)
      call
    end
  end

  describe '#requires_trial_dates?' do
    it 'never requires trial dates' do
      expect(claim.requires_trial_dates?).to be false
    end
  end

  describe '#requires_retrial_dates?' do
    it 'never requires retrial dates' do
      expect(claim.requires_retrial_dates?).to be false
    end
  end

  describe 'requires_case_type?' do
    it 'returns false' do
      expect(claim.requires_case_type?).to be false
    end
  end

  describe '#can_have_ppe?' do
    subject { claim.can_have_ppe? }

    let(:scheme) { 'lgfs' }

    before do
      claim.defendants.clear
      create(:defendant, claim:, scheme:)
      claim.reload

      FeeScheme.find_or_create_by(name: 'LGFS', version: 9, start_date: Date.parse('1 Jan 1970'), end_date: Settings.lgfs_scheme_10_clair_release_date.end_of_day - 1.day)
      FeeScheme.find_or_create_by(name: 'LGFS', version: 10, start_date: Settings.lgfs_scheme_10_clair_release_date.beginning_of_day)
    end

    context 'when case is not elected' do
      let(:options) { { elected_case: false } }

      it { is_expected.to be_truthy }
    end

    context 'when fee scheme is 9 and case is elected' do
      let(:options) { { elected_case: true } }

      it { is_expected.to be_falsey }
    end

    context 'when fee scheme is 10 and case is elected' do
      let(:options) { { elected_case: true } }
      let(:scheme) { 'lgfs scheme 10' }

      it { is_expected.to be_truthy }
    end
  end

  include_examples 'common litigator claim attributes'
end
