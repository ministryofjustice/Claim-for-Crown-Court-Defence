class ExpenseTypePresenter < BasePresenter
  presents :expense_type

  def data_attributes
    {
      location: location_field?,
      location_label: location_label,
      distance: distance_field?,
      mileage: mileage_field?,
      mileage_type: mileage_type,
      hours: hours_field?,
      reason_set: reason_set
    }
  end

  private

  def location_field?
    !parking?
  end

  def location_label
    if car_travel? || bike_travel? || train? || travel_time? || road_tolls? || cab_fares?
      'Destination'
    elsif hotel_accommodation? || subsistence?
      'Location'
    else
      ''
    end
  end

  def distance_field?
    car_travel? || bike_travel?
  end

  def mileage_field?
    car_travel? || bike_travel?
  end

  def mileage_type
    if car_travel?
      :car
    elsif bike_travel?
      :bike
    end
  end

  def hours_field?
    travel_time?
  end
end
