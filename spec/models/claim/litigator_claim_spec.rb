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
#

require 'rails_helper'
require 'custom_matchers'

RSpec.describe Claim::LitigatorClaim, type: :model do

  let(:claim)   { build :unpersisted_litigator_claim }

  describe 'validate creator provider is in LGFS fee scheme' do
    it 'rejects creators whose provider is only agfs' do
      claim.creator = build(:external_user, provider: build(:provider, :agfs))
      expect(claim).not_to be_valid
      expect(claim.errors[:creator]).to eq(["must be from a provider with permission to submit LGFS claims"])
    end

    it 'accepts creators whose provider is only lgfs' do
      claim.creator = build(:external_user, provider: build(:provider, :lgfs))
      expect(claim).to be_valid
    end

    it 'accepts creators whose provider is both agfs and lgfs' do
      claim.creator = build(:external_user, provider: build(:provider, :agfs_lgfs))
      expect(claim).to be_valid
    end
  end

  describe 'external_user_id' do
    it 'is not valid if present' do
      claim.external_user_id = 134
      expect(claim).not_to be_valid
      expect(claim.errors[:external_user_id]).to eq(['present'])
    end
  end

end
