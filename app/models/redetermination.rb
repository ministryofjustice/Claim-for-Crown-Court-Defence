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
#

class Redetermination < Determination

  self.table_name = 'determinations'

  belongs_to :claim

  default_scope   { order(:created_at)  }

end
