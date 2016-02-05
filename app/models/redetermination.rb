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

class Redetermination < Determination

  self.table_name = 'determinations'

  belongs_to :claim, class_name: Claim::BaseClaim, foreign_key: :claim_id

  has_paper_trail on: [:create, :update], only: [:fees, :expenses, :vat_amount, :total]
  before_save :set_paper_trail_event!

  default_scope   { order(:created_at)  }

  private

  def set_paper_trail_event!
    self.paper_trail_event = 'Redetermination made'
  end

end
