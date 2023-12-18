# == Schema Information
#
# Table name: supplier_numbers
#
#  id              :integer          not null, primary key
#  provider_id     :integer
#  supplier_number :string
#

class SupplierNumber < ApplicationRecord
  SUPPLIER_NUMBER_REGEX = /\A[0-9][A-Z][0-9]{3}[A-Z]\z/

  auto_strip_attributes :supplier_number, :name, :postcode, squish: true, nullify: true

  belongs_to :provider

  before_validation { supplier_number.upcase! if supplier_number.present? }

  validates :supplier_number,
            format: { with: SUPPLIER_NUMBER_REGEX, allow_nil: true },
            uniqueness: { case_sensitive: false },
            presence: true
  validates :postcode,
            format: { with: Settings.postcode_regexp, allow_nil: true }

  def to_s
    supplier_number
  end

  def has_non_archived_claims?
    # FIXME: For whatever reason claims don't actually have a relationship to SupplierNumber,
    #   instead storing the literal string supplier number in a string column. This needs to
    #   be fixed, but opens up a whole other can of worms. So for now we'll have this ugly
    #   hack.

    Claim::BaseClaim.non_archived_pending_delete.where(supplier_number:).any?
  end
end
