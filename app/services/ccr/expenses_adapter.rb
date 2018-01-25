module CCR
  class ExpensesAdapter
    attr_reader :expense

    TRANSLATION_TABLE = {
      'Bike travel' => {
        1 => 'AGFS_THE_TRV_BK',
        2 => 'AGFS_TCT_TRV_BK',
        3 => 'AGFS_TCT_TRV_BK',
        4 => 'AGFS_TCT_TRV_BK',
        5 => 'AGFS_THE_TRV_BK'
      },
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
        2 => 'AGFS_TCT_CNF_VW',
        3 => 'AGFS_TCT_CNF_VW',
        4 => 'AGFS_TCT_CNF_VW'
      },
      'Road or tunnel tolls' => {
        1 => 'AGFS_THE_TRV_CR',
        2 => 'AGFS_TCT_TRV_CR',
        3 => 'AGFS_TCT_TRV_CR',
        4 => 'AGFS_TCT_TRV_CR',
        5 => 'AGFS_THE_TRV_CR'
      },
      'Cab fares' => {
        1 => 'AGFS_THE_TRV_CR',
        2 => 'AGFS_TCT_TRV_CR',
        3 => 'AGFS_TCT_TRV_CR',
        4 => 'AGFS_TCT_TRV_CR',
        5 => 'AGFS_THE_TRV_CR'
      },
      'Subsistence' => {
        1 => 'AGFS_THE_HOT_ST',
        2 => 'AGFS_TCT_HOT_ST',
        3 => 'AGFS_TCT_HOT_ST',
        4 => 'AGFS_TCT_HOT_ST',
        5 => 'AGFS_THE_HOT_ST'
      }
    }.freeze

    def initialize(expense)
      @expense = expense
    end

    def description
      parts = [(expense.location ||= expense.expense_type.name)]
      parts << expense.reason_text || ''
      parts.join(' ').strip
    end

    def quantity
      case expense.expense_type.unique_code
      when 'CAR', 'BIKE'
        expense.distance
      when 'TRAVL'
        ((expense.hours * 4).ceil / 4.0)
      else
        1
      end
    end

    def rate
      case expense.expense_type.unique_code
      when 'CAR', 'BIKE'
        expense&.mileage_rate&.rate || 0
      when 'TRAVL'
        0
      else
        expense.amount
      end
    end

    def bill_type
      'AGFS_EXPENSES'
    end

    def bill_subtype
      TRANSLATION_TABLE[expense.expense_type.name][expense.reason_id] || nil
    end
  end
end
