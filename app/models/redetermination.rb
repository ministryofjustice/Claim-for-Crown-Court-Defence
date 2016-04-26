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

class Redetermination < Determination

  self.table_name = 'determinations'

  has_paper_trail on: [:create, :update], only: [:fees, :expenses, :disbursements, :vat_amount, :total]
  before_save :set_paper_trail_event!

  default_scope   { order(:created_at)  }

  private

  def set_paper_trail_event!
    self.paper_trail_event = 'Redetermination made'
  end

end
