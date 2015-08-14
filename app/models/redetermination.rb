class Redetermination < Determination

  self.table_name = 'determinations'

  belongs_to :claim

  default_scope   { order(:created_at)  }

end