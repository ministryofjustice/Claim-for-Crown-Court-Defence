# == Schema Information
#
# Table name: fee_types
#
#  id          :integer          not null, primary key
#  description :string
#  code        :string
#  created_at  :datetime
#  updated_at  :datetime
#  max_amount  :decimal(, )
#  calculated  :boolean          default(TRUE)
#  type        :string
#  roles       :string
#

module Fee

  class FeeBaseFeeTypeAbstractClassError
    def initialize(message = 'Fee::BaseFeeType is an abstract class and cannot be instantiated')
      super(message)
    end
  end

  class BaseFeeType < ActiveRecord::Base
    ROLES = %w{ lgfs agfs }
    include ActionView::Helpers::NumberHelper
    include Comparable
    include Roles

    self.table_name = 'fee_types'

    auto_strip_attributes :code, :description, squish: true, nullify: true

    has_many :fees, dependent: :destroy, class_name: Fee::BaseFee, foreign_key: :fee_type_id
    has_many :claims, through: :fees

    validates :description, presence: {message: 'Fee type description cannot be blank'}, uniqueness: { case_sensitive: false, scope: :type, message: 'Fee type description must be unique' }
    validates :code, presence: {message: 'Fee type code cannot be blank'}

    after_initialize :ensure_not_abstract_class

    def ensure_not_abstract_class
      raise FeeBaseFeeTypeAbstractClassError if self.class == BaseFeeType
    end

    def has_dates_attended?
      false
    end

    def pretty_max_amount
      number_to_currency(self.max_amount, precision: 0)
    end

    def fee_class_name
      self.type.sub(/Type$/, '')
    end

    #utility methods for providing access to subclasses

    def self.basic
      Fee::BasicFeeType.all
    end

    def self.misc
      Fee::MiscFeeType.all
    end

    def self.fixed
      Fee::FixedFeeType.all
    end

    def to_s
      sprintf('%3d %18s %4s %10s %s', self.id, self.type, self.code, self.roles.join(';'), self.description)
    end

    def <=> other
      sort_key <=> other.sort_key
    end

    def sort_key
      "#{self.type} #{self.description}"
    end
    
  private

    def self.by_fee_category(category)
      self.joins(:fee_category).where('fee_categories.abbreviation = ?', category.upcase).order(:description)
    end

  end
end
