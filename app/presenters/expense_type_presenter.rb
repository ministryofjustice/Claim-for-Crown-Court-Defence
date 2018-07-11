class ExpenseTypePresenter < BasePresenter
  presents :expense_type

  def data_attributes
    {
      date: true,
      distance: distance_field?,
      hours: hours_field?,
      location: location_field?,
      location_label: location_label,
      mileage: mileage_field?,
      mileage_type: mileage_type,
      net_amount: true,
      net_amount_label: net_amount_label,
      reason: true,
      reason_set: reason_set,
      vat_amount: true
    }
  end

  private

  def location_field?
    !parking?
  end

  def location_label
    if destination_field?
      'Destination'
    elsif hotel_accommodation? || subsistence?
      'Location'
    else
      ''
    end
  end

  def net_amount_label
    'Net amount'
  end

  def destination_field?
    car_travel? || bike_travel? || train? || travel_time? || road_tolls? || cab_fares?
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
