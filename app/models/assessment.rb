# == Schema Information
#
# Table name: determinations
#
#  id         :integer          not null, primary key
#  claim_id   :integer
#  type       :string
#  fees       :decimal(, )
#  expenses   :decimal(, )
#  total      :decimal(, )
#  created_at :datetime
#  updated_at :datetime
#  vat_amount :float            default(0.0)
#

class Assessment < Determination

  self.table_name = 'determinations'

  has_paper_trail on: [:update], only: [:fees, :expenses, :vat_amount, :total]

  after_initialize :set_default_values
  before_save :set_paper_trail_event!

  # validates :claim_id, uniqueness: { message: 'This claim already has an assessment' }

  belongs_to :claim

  def set_default_values
    if new_record?
      self.fees = 0
      self.expenses = 0
    end
  end

  def zeroize!
    self.fees = 0
    self.expenses = 0
    self.save!
  end

  private

  def set_paper_trail_event!
    self.paper_trail_event = 'Assessment made'
  end

end
