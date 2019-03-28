module DemoData
  class ExpenseGenerator
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
      @claim.travel_expense_additional_information = Faker::Lorem.paragraph(1)
      @claim.save
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

    def generate_travel_expense_additional_info
      [
        'It was the best of times, it was the worst of times.',
        'Last night I dreamt of Manderley again.',
        'It is a truth universally acknowledged, that a single man in possession of a good fortune must be in want of a wife.',
        'Happy families are all alike; every unhappy family is unhappy in its own way.',
        'It was a bright cold day in April, and the clocks were striking thirteen.',
        'I am an invisible man.',
        'Stately, plump Buck Mulligan came from the stairhead, bearing a bowl of lather on which a mirror and a razor lay crossed.',
        'All this happened, more or less.',
        'The moment one learns English, complications set in.',
        'He was an old man who fished alone in a skiff in the Gulf Stream and he had gone eighty-four days now without taking a fish.',
        'It was the day my grandmother exploded.',
        'It was love at first sight. The first time Yossarian saw the chaplain, he fell madly in love with him.',
        'I have never begun a novel with more misgiving.',
        'You better not never tell nobody but God.',
        'The past is a foreign country; they do things differently there.',
        'He was born with a gift of laughter and a sense that the world was mad.',
        'In the town, there were two mutes and they were always together.',
        'The cold passed reluctantly from the earth, and the retiring fogs revealed an army stretched out on the hills, resting.'
      ].sample
    end

  end
end
