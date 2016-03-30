class ExpenseTypePresenter < BasePresenter
  presents :expense_type

  def data_attributes
    {
      location: location_field?,
      location_label: location_label,
      distance: distance_field?,
      mileage: mileage_field?,
      hours: hours_field?,
      reason_set: reason_set
    }
  end


  private

  def location_field?
    car_travel? || train? || travel_time? || hotel_accommodation?
  end

  def location_label
    if car_travel? || train? || travel_time?
      'Destination'
    elsif hotel_accommodation?
      'Location'
    else
      ''
    end
  end

  def distance_field?
    car_travel? || train?
  end

  def mileage_field?
    car_travel?
  end

  def hours_field?
    travel_time?
  end
end
