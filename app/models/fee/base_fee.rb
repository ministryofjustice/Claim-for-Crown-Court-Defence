# == Schema Information
#
# Table name: fees
#
#  id                    :integer          not null, primary key
#  claim_id              :integer
#  fee_type_id           :integer
#  quantity              :decimal(, )
#  amount                :decimal(, )
#  created_at            :datetime
#  updated_at            :datetime
#  uuid                  :uuid
#  rate                  :decimal(, )
#  type                  :string
#  warrant_issued_date   :date
#  warrant_executed_date :date
#  sub_type_id           :integer
#  case_numbers          :string
#  date                  :date
#

module Fee
  class BaseFeeAbstractClassError < RuntimeError
    def initialize(message = 'Fee::BaseFee is an abstract class and cannot be instantiated')
      super(message)
    end
  end

  class BaseFee < ApplicationRecord
    include NumberCommaParser
    include Duplicable

    self.table_name = 'fees'
    numeric_attributes :quantity, :amount

    auto_strip_attributes :case_numbers, squish: true, nullify: true

    belongs_to :claim, class_name: 'Claim::BaseClaim', foreign_key: :claim_id
    belongs_to :fee_type, class_name: 'Fee::BaseFeeType'
    belongs_to :sub_type, class_name: 'Fee::BaseFeeType'

    delegate :description, :case_uplift?, :position, to: :fee_type
    delegate :defendant_uplift?, to: :fee_type, allow_nil: true

    has_many :dates_attended, as: :attended_item, dependent: :destroy, inverse_of: :attended_item

    default_scope { includes(:fee_type) }

    scope :defendant_uplift_sums, lambda {
      joins(:fee_type)
        .merge(Fee::BaseFeeType.defendant_uplifts)
        .unscope(:order)
        .group('fee_types.unique_code')
        .sum('quantity')
    }

    validates_with FeeSubModelValidator

    accepts_nested_attributes_for :dates_attended, reject_if: :all_blank, allow_destroy: true

    after_initialize do
      ensure_not_abstract_class
    end

    def ensure_not_abstract_class
      raise BaseFeeAbstractClassError if self.class == BaseFee
    end

    def set_defaults
      self.quantity   = 0 if quantity.blank?
      self.rate       = 0 if rate.blank?
      self.amount     = 0 if amount.blank?
      calculate_amount
    end

    before_validation :set_defaults

    after_save do
      claim.update_fees_total
      claim.update_total
      claim.update_vat
    end

    after_destroy do
      claim.update_fees_total
      claim.update_total
      claim.update_vat
    end

    def quantity_is_decimal?
      return false if fee_type.nil?
      fee_type.quantity_is_decimal?
    end

    # default type logic
    def is_basic?
      false
    end

    def is_misc?
      false
    end

    def is_fixed?
      false
    end

    def is_graduated?
      false
    end

    def is_warrant?
      false
    end

    def is_interim?
      false
    end

    def is_transfer?
      false
    end

    # Prevent invalid fees from being created through the JSON importer,
    # because once created they cannot be amended on the web UI.
    #
    def perform_validation?
      claim&.perform_validation? || claim&.from_json_import?
    end

    def calculated?
      fee_type&.calculated?.nil? ? true : fee_type&.calculated?
    end

    def calculation_required?
      # NOTE:
      #   - agfs fixed fees and misc fees are calculated, except for old claims (non-draft) that can have nil/0 rate
      #   - agfs basic fees are calculated based on fee type, except for old claims (non-draft) that can have nil/0 rate
      #   - no lgfs fees are calculated, regardless
      claim&.editable? && claim.agfs? && calculated?
    end

    def calculate_amount
      return unless calculation_required?
      return unless quantity && rate
      self.amount = quantity * rate
    end

    def blank?
      [0, nil].include?(quantity) && [0, nil].include?(amount) && [0, nil].include?(rate)
    end

    def present?
      !blank?
    end

    def clear
      self.quantity = nil
      self.rate = nil
      self.amount = nil
      self.case_numbers = nil
      # explicitly destroy child relations
      dates_attended.destroy_all unless dates_attended.empty?
    end
  end
end
