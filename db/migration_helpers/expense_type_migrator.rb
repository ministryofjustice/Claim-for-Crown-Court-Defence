module MigrationHelpers
  class ExpenseTypeMigrator

    def initialize
      @car = ExpenseType.find_by(name: 'Car travel')
      @train = ExpenseType.find_by(name: 'Train/public transport')
      @parking = ExpenseType.find_by(name: 'Parking')
      @hotel = ExpenseType.find_by(name: 'Hotel accommodation')
      raise "No such expense type: Car travel" if @car.nil?
      raise "No such expense type: Train/public transport" if @train.nil?
      raise "No such expense type: Parking" if @parking.nil?
      raise "No such expense type: Hotel accommodation" if @hotel.nil?
    end

    def run
      expenses = Expense.all
      expenses.each { |ex| migrate_expense(ex) }
    end

  private
    def migrate_conference_view_and_car(ex)
      ex.expense_type = @car
      ex.reason_id = 5
      narrative = extract_and_update_date_info(ex)
      ex.reason_text = "Other: Originally Conference and View  #{narrative}"
    end

    def extract_and_update_date_info(ex)
      date, narrative = extract_date_and_narrative_from_dates(ex)
      ex.date = date
      narrative
    end

    def extract_date_and_narrative_from_dates(ex)
      if is_single_date?(ex.dates_attended)
        date = ex.dates_attended.first.date
        narrative = ""
      else
        date = ex.dates_attended.first.date
        narrative = extract_date_ranges_as_text(ex)
      end
      [date, narrative]
    end

    def is_single_date?(dates_attended)
      dates_attended.size == 1 && refers_to_one_date?(dates_attended.first)
    end

    def refers_to_one_date?(date_attended)
      date_attended.date_to.nil? || date_attended.date == date_attended.date_to
    end


    def migrate_expense(ex)
      case ex.expense_type.name.upcase
      when 'CONFERENCE AND VIEW - CAR'
        migrate_conference_view_and_car(ex)

      when 'CONFERENCE AND VIEW - HOTEL STAY'
        ex.expense_type = @hotel
        ex.reason_id = 5
        ex.reason_text = 'Other: Conference and View'

      when 'CONFERENCE AND VIEW - TRAIN'
        ex.expense_type = @train
        ex.reason_id = 5
        ex.reason_text = 'Other: Conference and View'
      
      when 'CONFERENCE AND VIEW - TRAVEL TIME'
        ex.expense_type = @train
        ex.reason_id = 5
        ex.reason_text = 'Other: Conference and View'
      
      when 'TRAVEL AND HOTEL - CAR'
        ex.expense_type = @car
        ex.reason_id = 5
        ex.reason_text = 'Other: Conference and View'
      
      when 'TRAVEL AND HOTEL - CONFERENCE AND VIEW'
        ex.expense_type = @hotel
        ex.reason_id = 5
        ex.reason_text = 'Other: Conference and View'
      
      when 'TRAVEL AND HOTEL - HOTEL STAY'
        ex.expense_type = @hotel
        ex.reason_id = 5
        ex.reason_text = 'Other: Conference and View'
      
      when 'TRAVEL AND HOTEL - TRAIN'
        ex.expense_type = @train
        ex.reason_id = 5
        ex.reason_text = 'OTHER: CONFERENCE AND VIEW'
      else
        raise RuntimeError, "Unrecognised expense type name: '#{ex.expense_type.name}'"
      end
      ex.save!
    end
  end
end
