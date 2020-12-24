# == Schema Information
#
# Table name: claims
#
#  id                       :integer          not null, primary key
#  additional_information   :text
#  apply_vat                :boolean
#  state                    :string
#  last_submitted_at        :datetime
#  case_number              :string
#  advocate_category        :string
#  first_day_of_trial       :date
#  estimated_trial_length   :integer          default(0)
#  actual_trial_length      :integer          default(0)
#  fees_total               :decimal(, )      default(0.0)
#  expenses_total           :decimal(, )      default(0.0)
#  total                    :decimal(, )      default(0.0)
#  external_user_id         :integer
#  court_id                 :integer
#  offence_id               :integer
#  created_at               :datetime
#  updated_at               :datetime
#  valid_until              :datetime
#  cms_number               :string
#  authorised_at            :datetime
#  creator_id               :integer
#  evidence_notes           :text
#  evidence_checklist_ids   :string
#  trial_concluded_at       :date
#  trial_fixed_notice_at    :date
#  trial_fixed_at           :date
#  trial_cracked_at         :date
#  trial_cracked_at_third   :string
#  source                   :string
#  vat_amount               :decimal(, )      default(0.0)
#  uuid                     :uuid
#  case_type_id             :integer
#  form_id                  :string
#  original_submission_date :datetime
#  retrial_started_at       :date
#  retrial_estimated_length :integer          default(0)
#  retrial_actual_length    :integer          default(0)
#  retrial_concluded_at     :date
#  type                     :string
#  disbursements_total      :decimal(, )      default(0.0)
#  case_concluded_at        :date
#  transfer_court_id        :integer
#  supplier_number          :string
#  effective_pcmh_date      :date
#  legal_aid_transfer_date  :date
#  allocation_type          :string
#  transfer_case_number     :string
#  clone_source_id          :integer
#  last_edited_at           :datetime
#  deleted_at               :datetime
#  providers_ref            :string
#  disk_evidence            :boolean          default(FALSE)
#  fees_vat                 :decimal(, )      default(0.0)
#  expenses_vat             :decimal(, )      default(0.0)
#  disbursements_vat        :decimal(, )      default(0.0)
#  value_band_id            :integer
#  retrial_reduction        :boolean          default(FALSE)
#

require 'rails_helper'
require_relative 'shared_examples_for_lgfs_claim'

describe Claim::TransferClaim, type: :model do
  let(:claim) { build :transfer_claim }

  it { should_not delegate_method(:requires_trial_dates?).to(:case_type) }
  it { should_not delegate_method(:requires_retrial_dates?).to(:case_type) }

  context 'should delegate transfer detail attributes to transfer detail object' do
    [:litigator_type, :elected_case, :transfer_stage_id, :transfer_date, :transfer_date_dd, :transfer_date_mm, :transfer_date_yyyy, :case_conclusion_id].
    each do |attribute|
      it { should delegate_method(attribute).to(:transfer_detail) }
    end
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
    it 'should return only Interim case types' do
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
    it 'should return true' do
      expect(claim.transfer?).to eql true
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
      expect(claim.requires_trial_dates?).to eql false
    end
  end

  describe '#requires_retrial_dates?' do
    it 'never requires retrial dates' do
      expect(claim.requires_retrial_dates?).to eql false
    end
  end

  describe 'requires_case_type?' do
    it 'returns false' do
      expect(claim.requires_case_type?).to be false
    end
  end

  include_examples 'common litigator claim attributes'
end
