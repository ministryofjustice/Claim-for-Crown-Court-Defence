# == Schema Information
#
# Table name: fee_types
#
#  id                  :integer          not null, primary key
#  description         :string
#  code                :string
#  created_at          :datetime
#  updated_at          :datetime
#  max_amount          :decimal(, )
#  calculated          :boolean          default(TRUE)
#  type                :string
#  roles               :string
#  parent_id           :integer
#  quantity_is_decimal :boolean          default(FALSE)
#  unique_code         :string
#

module Fee
  DEFAULT_MSG = 'Fee::BaseFeeType is an abstract class and cannot be instantiated'.freeze
  class BaseFeeTypeAbstractClassError < RuntimeError
    def initialize(message = DEFAULT_MSG)
      super
    end
  end

  class BaseFeeType < ApplicationRecord
    ROLES = %w[
      lgfs lgfs_scheme_9 lgfs_scheme_10 lgfs_scheme_11
      agfs agfs_scheme_9 agfs_scheme_10 agfs_scheme_12 agfs_scheme_13 agfs_scheme_14 agfs_scheme_15 agfs_scheme_16
    ].freeze
    include ActionView::Helpers::NumberHelper
    include Comparable
    include Roles
    include CaseUpliftable
    include DefendantUpliftable

    self.table_name = 'fee_types'

    auto_strip_attributes :code, :description, squish: true, nullify: true

    has_many :fees, dependent: :destroy, class_name: 'Fee::BaseFee', foreign_key: :fee_type_id
    has_many :claims, -> { active }, through: :fees

    validates :description, presence: true, uniqueness: { case_sensitive: false, scope: :type }
    validates :code, presence: true
    validates :unique_code, presence: true

    after_initialize :ensure_not_abstract_class

    def ensure_not_abstract_class
      raise BaseFeeTypeAbstractClassError, DEFAULT_MSG if instance_of?(BaseFeeType)
    end

    def requires_dates_attended?
      false
    end

    def pretty_max_amount
      number_to_currency(max_amount, precision: 0)
    end

    def fee_class_name
      type.sub(/Type$/, '')
    end

    # utility methods for providing access to subclasses

    def self.basic
      Fee::BasicFeeType.all
    end

    def self.misc
      Fee::MiscFeeType.all
    end

    def self.fixed
      Fee::FixedFeeType.all
    end

    def self.warrant
      Fee::WarrantFeeType.all
    end

    def self.graduated
      Fee::GraduatedFeeType.all
    end

    def self.interim
      Fee::InterimFeeType.all
    end

    def self.transfer
      Fee::TransferFeeType.all
    end

    def self.find_by_id_or_unique_code(id_or_code)
      if id_or_code.to_s.digit?
        find_by(id: id_or_code)
      else
        find_by(unique_code: id_or_code)
      end
    end
  end
end
