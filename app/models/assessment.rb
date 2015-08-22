# == Schema Information
#
# Table name: determinations
#
#  id         :integer          not null, primary key
#  claim_id   :integer
#  type       :string(255)
#  fees       :decimal(, )
#  expenses   :decimal(, )
#  total      :decimal(, )
#  created_at :datetime
#  updated_at :datetime
#

class Assessment < Determination

  self.table_name = 'determinations'

  after_initialize :set_default_values

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

end
