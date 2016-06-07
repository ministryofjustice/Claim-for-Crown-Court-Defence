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
#

module Claim
  class TransferClaim < BaseClaim
    set_singular_route_key 'litigators_transfer_claim'

    has_one :transfer_detail, foreign_key: :claim_id, class_name: Claim::TransferDetail, dependent: :destroy
    has_one :transfer_fee, foreign_key: :claim_id, class_name: Fee::TransferFee, dependent: :destroy, inverse_of: :claim

    accepts_nested_attributes_for :transfer_detail, reject_if: :all_blank, allow_destroy: false
    accepts_nested_attributes_for :transfer_fee, reject_if: :all_blank, allow_destroy: false

    validates_with ::Claim::TransferClaimValidator
    validates_with ::Claim::TransferClaimSubModelValidator

    # The ActiveSupport delegate method doesn't work with new objects - i.e. You can't say Claim.new(xxx: value) where xxx is delegated
    # So we have to do this instead.  Probably good to put it in a gem eventually.
    #
    DELEGATED_ATTRS = [ :litigator_type, :elected_case, :transfer_stage_id, :transfer_date, :transfer_date_dd, :transfer_date_mm, :transfer_date_yyyy, :case_conclusion_id ]

    DELEGATED_ATTRS.each do |getter_method|
      define_method getter_method do
        proxy_transfer_detail.__send__(getter_method)
      end

      setter_method = "#{getter_method}=".to_sym
      define_method setter_method do |value|
        proxy_transfer_detail.__send__(setter_method, value)
      end
    end

    def lgfs?; true; end
    def transfer?; true; end
    def requires_trial_dates?; false; end
    def requires_retrial_dates?; false; end

    def proxy_transfer_detail
      self.transfer_detail ||= TransferDetail.new
    end

    def external_user_type
      :litigator
    end

    def eligible_case_types
      CaseType.lgfs
    end

    def eligible_misc_fee_types
      Fee::MiscFeeType.lgfs
    end

    private

    # called from state_machine before_submit
    def set_allocation_type
      self.allocation_type = self.transfer_detail.allocation_type
    end

    def provider_delegator
      provider
    end
  end
end
