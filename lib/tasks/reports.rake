namespace :reports do
  desc 'Retrieve car travel expenses data for providers'
  task providers_car_travel_expenses_data: :environment do
    results = Reports::FetchProvidersCarTravelData.call
    # TODO: this needs to likely export the data rather than just
    # outputing it
    puts results
  end
end
