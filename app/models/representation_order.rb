# == Schema Information
#
# Table name: representation_orders
#
#  id                        :integer          not null, primary key
#  defendant_id              :integer
#  created_at                :datetime
#  updated_at                :datetime
#  granting_body             :string(255)
#  maat_reference            :string(255)
#  representation_order_date :date
#  uuid                      :uuid
#

class RepresentationOrder < ActiveRecord::Base

  before_save :upcase_maat_ref

  validates   :granting_body, presence: true, unless: :do_not_validate?
  validates   :granting_body, inclusion: { in: Settings.court_types }
  validates   :maat_reference, presence: true, unless: :do_not_validate?
  validates   :maat_reference, uniqueness: { case_sensitive: false }
  validates   :representation_order_date, presence: true

  belongs_to :defendant

  def claim
    self.defendant.try(:claim)
  end

  def upcase_maat_ref
    self.maat_reference.upcase! unless self.maat_reference.blank?
  end

  def detail
    "#{self.granting_body} #{self.representation_order_date.strftime(Settings.date_format)} #{self.maat_reference}"
  end

  def do_not_validate?
    claim.nil? || belongs_to_draft_claim_from_web?
  end

  def belongs_to_draft_claim_from_web?
    claim.draft? == true && claim.source == 'web' # validations do apply to drafts from api
  end

end
