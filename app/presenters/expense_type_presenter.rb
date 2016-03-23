class ExpenseTypePresenter < BasePresenter
  presents :expense_type

  def data_attributes
    {
      destination: destination_field?,
      location: location_field?,
      distance: distance_field?,
      mileage: mileage_field?,
      hours: hours_field?,
      reason_set: reason_set
    }
  end


  private

  def destination_field?
    car_travel? || train? || travel_time?
  end

  def location_field?
    hotel_accommodation?
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
