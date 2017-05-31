class WorkingDayCalculator
  def initialize(start_date, end_date)
    @start_date = start_date.to_date
    @end_date = end_date.to_date
    @num_days = (end_date - start_date).to_i
  end

  def working_days
    num_days = 0
    d1 = first_working_day_after(@start_date)

    while d1 < @end_date
      d1 += 1.day
      num_days += 1 if working_day?(d1)
    end
    num_days
  end

  private

  def working_day?(date)
    date.wday != 6 && date.wday != 0
  end

  def not_working_day?(date)
    !working_day?(date)
  end

  def first_working_day_after(date)
    date += 1.day while not_working_day?(date)
    date
  end
end
