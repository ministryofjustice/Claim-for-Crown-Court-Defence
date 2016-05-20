# == Schema Information
#
# Table name: fees
#
#  id                    :integer          not null, primary key
#  claim_id              :integer
#  fee_type_id           :integer
#  quantity              :integer
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
#

module Fee

  class BaseFeeAbstractClassError < RuntimeError
    def initialize(message = 'Fee::BaseFee is an abstract class and cannot be instantiated')
      super(message)
    end
  end

  class BaseFee < ActiveRecord::Base
    include NumberCommaParser
    include Duplicable

    self.table_name = 'fees'
    numeric_attributes :quantity, :amount

    auto_strip_attributes :case_numbers, squish: true, nullify: true

    belongs_to :claim, class_name: Claim::BaseClaim, foreign_key: :claim_id
    belongs_to :fee_type, class_name: Fee::BaseFeeType
    belongs_to :sub_type, class_name: Fee::BaseFeeType

    has_many :dates_attended, as: :attended_item, dependent: :destroy, inverse_of: :attended_item

    default_scope { includes(:fee_type) }

    validates_with FeeSubModelValidator

    accepts_nested_attributes_for :dates_attended, reject_if: :all_blank, allow_destroy: true

    after_initialize :ensure_not_abstract_class

    def ensure_not_abstract_class
      raise BaseFeeAbstractClassError if self.class == BaseFee
    end

    before_validation do
      self.quantity   = 0 if self.quantity.blank?
      self.rate       = 0 if self.rate.blank?
      self.amount     = 0 if self.amount.blank?
      calculate_amount
    end

    after_save do
      claim.update_fees_total
      claim.update_total
    end

    after_destroy do
      claim.update_fees_total
      claim.update_total
      claim.update_vat
    end

    # default type logic
    def is_basic?; false; end
    def is_misc?; false; end
    def is_fixed?; false;end
    def is_graduated?; false; end
    def is_warrant?; false; end
    def is_interim?; false; end
    def is_transfer?; false; end

    def perform_validation?
      claim && claim.perform_validation?
    end

    def calculated?
      fee_type.calculated? rescue true
    end

    def calculation_required?
      # NOTE:
      #   - agfs fixed fees and misc fees are calculated, except for old claims (non-draft) that can have nil/0 rate
      #   - agfs basic fees are calculated based on fee type, except for old claims (non-draft) that can have nil/0 rate
      #   - no lgfs fees are calculated, regardless
      claim && claim.editable? && claim.agfs? && calculated?
    end

    def calculate_amount
      return unless calculation_required?
      self.amount = self.quantity * self.rate
    end

    def blank?
      [0, nil].include?(self.quantity) && [0, nil].include?(self.amount) && [0, nil].include?(self.rate)
    end

    def present?
      !blank?
    end

    def description
      fee_type.description
    end

    def category
      fee_type.fee_category.abbreviation
    end

    def clear
      self.quantity = nil;
      self.rate = nil;
      self.amount = nil;
      # explicitly destroy child relations
      self.dates_attended.destroy_all unless self.dates_attended.empty?
    end

  end
end
