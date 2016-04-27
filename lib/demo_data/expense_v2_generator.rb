module DemoData

  class ExpenseV2Generator

    def initialize(claim)
      @claim         = claim
      @expense_types = ExpenseType.all
      @ids_added     = []
    end

    def generate!
      rand(0..3).times { add_expense }
    end

    private

    def add_expense
      expense_type = @expense_types.sample
      while @ids_added.include?(expense_type.id)
        expense_type = @expense_types.sample
      end
      @ids_added << expense_type.id

      ex = Expense.new(claim: @claim, expense_type: expense_type)
      ex.location = generate_location(ex)
      ex.quantity = generate_quantity(ex)
      ex.rate = rand(1.0..99.99).round(2)
      ex.amount = rand(100.0..2500.0)
      ex.reason_id = generate_expense_reason_id(ex)
      ex.reason_text = generate_reason_text(ex)
      ex.distance = generate_distance(ex)
      ex.mileage_rate_id = generate_mileage_rate_id(ex)
      ex.date = rand(5..30).days.ago
      ex.hours = generate_hours(ex)

      ex.save!
    end

    def generate_location(ex)
      ex.parking? ? nil : Faker::Address.city
    end

    def generate_quantity(ex)
      ex.travel_time? ? nil : rand(1..10).round(2)
    end

    def generate_expense_reason_id(ex)
      ex.expense_reasons.map(&:id).sample
    end

    def generate_reason_text(ex)
      ex.expense_reason_other? ? Faker::Hacker.say_something_smart : nil
    end

    def generate_distance(ex)
      ex.car_travel? ? rand(1..500) : nil
    end

    def generate_mileage_rate_id(ex)
      ex.car_travel? ? rand(1..2) : nil
    end

    def generate_hours(ex)
      ex.travel_time? ? rand(1..8) : nil
    end
  end
end

