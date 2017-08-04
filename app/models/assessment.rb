# == Schema Information
#
# Table name: determinations
#
#  id            :integer          not null, primary key
#  claim_id      :integer
#  type          :string
#  fees          :decimal(, )      default(0.0)
#  expenses      :decimal(, )      default(0.0)
#  total         :decimal(, )
#  created_at    :datetime
#  updated_at    :datetime
#  vat_amount    :float            default(0.0)
#  disbursements :decimal(, )      default(0.0)
#

# The Assessment class represents the first assessment the case workers make on a claim. Any subsequent assessments are called
# determinations. There can be many determinations per claim, but only one assessment.  An assessment with zero values
# (blank? returns true) is created automatically when the claim is created.
#
# The correct way to create a non-blank assessment for a claim is to call #update_values on the blank Assessment that is created
# when the claim is created.  This will raise an error if the assessment is not blank.  The #update_values! (note the bang) can
# be used in testing and will not raise if the assessment already has values.
#
class Assessment < Determination
  self.table_name = 'determinations'

  has_paper_trail on: [:update], only: %i[fees expenses disbursements vat_amount total]

  after_initialize :set_default_values
  before_save :set_paper_trail_event!
  validates :claim_id, uniqueness: { message: 'This claim already has an assessment' }

  def set_default_values
    zeroize if new_record?
  end

  def zeroize
    self.fees = 0
    self.expenses = 0
    self.disbursements = 0
  end

  def zeroize!
    zeroize
    save!
  end

  def update_values(*args)
    raise 'Cannot update a non-blank assessment' unless blank?
    update_values!(*args)
  end

  def update_values!(fees, expenses, disbursements, time = Time.now)
    self.fees = fees unless fees.nil?
    self.expenses = expenses unless expenses.nil?
    self.disbursements = disbursements unless disbursements.nil?
    self.created_at = time
    save!
  end

  private

  def set_paper_trail_event!
    self.paper_trail_event = 'Assessment made'
  end
end
