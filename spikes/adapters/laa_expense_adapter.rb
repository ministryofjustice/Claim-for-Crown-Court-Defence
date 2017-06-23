class LaaExpenseAdapter
  TRANSLATION_TABLE = {
    'Car travel' => {
      1 => 'AGFS_THE_TRV_CR',
      2 => 'AGFS_TCT_TRV_CR',
      3 => 'AGFS_TCT_TRV_CR',
      4 => 'AGFS_TCT_TRV_CR',
      5 => 'AGFS_THE_TRV_CR'
    },
    'Parking' => {
      1 => 'AGFS_THE_TRV_CR',
      2 => 'AGFS_TCT_TRV_CR',
      3 => 'AGFS_TCT_TRV_CR',
      4 => 'AGFS_TCT_TRV_CR',
      5 => 'AGFS_THE_TRV_CR'
    },
    'Hotel accommodation' => {
      1 => 'AGFS_THE_HOT_ST',
      2 => 'AGFS_TCT_HOT_ST',
      3 => 'AGFS_TCT_HOT_ST',
      4 => 'AGFS_TCT_HOT_ST',
      5 => 'AGFS_THE_HOT_ST'
    },
    'Train/public transport' => {
      1 => 'AGFS_THE_TRV_TR',
      2 => 'AGFS_TCT_TRV_TR',
      3 => 'AGFS_TCT_TRV_TR',
      4 => 'AGFS_TCT_TRV_TR',
      5 => 'AGFS_THE_TRV_TR'
    },
    'Travel time' => {
      1 => nil,
      2 => 'AGFS_TCT_CNF_VW',
      3 => 'AGFS_TCT_CNF_VW',
      4 => 'AGFS_TCT_CNF_VW',
      5 => nil
    },
    'Road or tunnel tolls' => {
      1 => 'AGFS_THE_TRV_CR',
      2 => 'AGFS_THE_TRV_CR',
      3 => 'AGFS_THE_TRV_CR',
      4 => 'AGFS_THE_TRV_CR',
      5 => 'AGFS_THE_TRV_CR'
    },
    'Cab fares' => {
      1 => 'AGFS_THE_TRV_TR',
      2 => 'AGFS_TCT_TRV_TR',
      3 => 'AGFS_TCT_TRV_TR',
      4 => 'AGFS_TCT_TRV_TR',
      5 => 'AGFS_THE_TRV_TR'
    },
    'Subsistence' => {
      1 => 'AGFS_THE_HOT_ST',
      2 => 'AGFS_TCT_HOT_ST',
      3 => 'AGFS_TCT_HOT_ST',
      4 => 'AGFS_TCT_HOT_ST',
      5 => 'AGFS_TCT_HOT_ST'
    }
  }.freeze

  LAA_BILL_TYPE = 'AGFS_EXPENSES'.freeze

  def self.laa_bill_type_and_sub_type(expense)
    subtype = TRANSLATION_TABLE[expense.expense_type.name][expense.reason_id]
    subtype.nil? ? nil : [LAA_BILL_TYPE, subtype]
  end
end
