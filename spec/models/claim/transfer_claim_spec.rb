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
#

require "rails_helper"
require "custom_matchers"

describe Claim::TransferClaim, type: :model do

  let(:claim) { build :transfer_claim }

  describe '.new' do
    let(:today) { Date.today }

    it 'creates an empty transfer detail class upon instantiation of a new object' do
      claim = Claim::TransferClaim.new
      expect(claim.transfer_detail).not_to be_nil
      expect(claim.transfer_detail).to be_unpopulated
    end

    it 'populates transfer detail with transfer detail attributes' do
      claim = Claim::TransferClaim.new(case_number: 'A12345678', litigator_type: "new", elected_case: false, transfer_stage_id: 10, transfer_date: today, case_conclusion_id: 30)
      expect(claim.case_number).to eq 'A12345678'
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

  describe '#vat_registered?' do
    it 'returns the value from the provider' do
      expect(claim.provider).to receive(:vat_registered?)
      claim.vat_registered?
    end
  end
end
