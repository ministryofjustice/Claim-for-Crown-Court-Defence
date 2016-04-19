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

module Claim
  class LitigatorClaim < BaseClaim

    validates_with ::Claim::LitigatorClaimValidator
    validates_with ::Claim::LitigatorClaimSubModelValidator

    belongs_to :transfer_court, foreign_key: 'transfer_court_id', class_name: 'Court'

    has_one :fixed_fee, foreign_key: :claim_id, class_name: 'Fee::FixedFee', dependent: :destroy, inverse_of: :claim
    has_one :warrant_fee, foreign_key: :claim_id, class_name: 'Fee::WarrantFee', dependent: :destroy, inverse_of: :claim
    has_one :graduated_fee, foreign_key: :claim_id, class_name: 'Fee::GraduatedFee', dependent: :destroy, inverse_of: :claim

    accepts_nested_attributes_for :fixed_fee, reject_if: :all_blank, allow_destroy: false
    accepts_nested_attributes_for :warrant_fee, reject_if: :all_blank, allow_destroy: false
    accepts_nested_attributes_for :graduated_fee, reject_if: :all_blank, allow_destroy: false

    # LGFS allocation filtering scopes
    scope :graduated_fees,        -> { where(case_type_id: CaseType.graduated_fees.pluck(:id) ) }

    # TODO: An "interim fees" filter is for claims that are of type Claim::InterimClaim and have an interim fee that is of type Effective PCMH, Trial Start, Retrial New Solicitor or Retrial Start
    # scope :interim_fees,          -> { where() }

    # TODO: An "interim disbursments" filter is for claims that are of Type Claim::InterimClaim and have a fee type of disbursment only (This is to be done)
    # TODO: no case type available yet
    # scope :interim_disbursements, -> { where() }

    # TODO: A "warrants" filter is for claims that are of Type Claim::InterimClaim and have a fee type of Warrant
    # scope :warrants,              -> { where() }

    # A "Risk based bill" is a claim that is considered low risk
    # This filter is for claims that have a case type of Guilty plea and an offence that is of class E, F, H or I and a PPE fee of 50 or less
    scope :risk_based_bills,      -> { where(case_type_id: CaseType.ids_by_types('Guilty plea')).where(offence_id: Offence.joins(:offence_class).where(offence_class: { class_letter: ['E','F','H','I'] })) }

    def eligible_case_types
      CaseType.lgfs
    end

    def eligible_basic_fee_types
      Fee::BasicFeeType.lgfs
    end

    def eligible_misc_fee_types
      Fee::MiscFeeType.lgfs
    end

    def eligible_fixed_fee_types
      Fee::FixedFeeType.top_levels.lgfs
    end

    def supplier_number_regex
      SupplierNumber::SUPPLIER_NUMBER_REGEX
    end

    def external_user_type
      :litigator
    end


    private

    def provider_delegator
      provider
    end

    def destroy_all_invalid_fee_types
      if case_type.present? && case_type.is_fixed_fee?
        basic_fees.map(&:clear) unless basic_fees.empty?
      else
        fixed_fee.try(:delete)
      end
    end
  end
end
