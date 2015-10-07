module DemoData

  class ExpenseGenerator

    def initialize(claim)
      @claim         = claim
      @expense_types = ExpenseType.all
      @ids_added     = []
    end

    def generate!
      rand(0..5).times { add_expense }
    end

    private

    def add_expense
      expense_type = @expense_types.sample
      while @ids_added.include?(expense_type.id)
        expense_type = @expense_types.sample
      end
      expense = Expense.create(claim: @claim, expense_type: expense_type, quantity: rand(1..10), rate: rand(1.0..99.99),amount: rand(100.0..2500.0), location: Faker::Address.city)
      @ids_added << expense_type.id
    end
  
  end
end

