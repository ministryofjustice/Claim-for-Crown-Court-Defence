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

class Determination < ActiveRecord::Base


  before_save :calculate_total

  belongs_to :claim

  validates :fees,         numericality: { greater_than_or_equal_to: 0, message: 'Assessed fees must be greater than or equal to zero'}
  validates :expenses,     numericality: { greater_than_or_equal_to: 0, message: 'Assessed expenses must be greater than or equal to zero'}



  def calculate_total
    self.total = self.fees + self.expenses
  end

  
end
