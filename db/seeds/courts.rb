require 'open-uri'

courts_json = open("https://courttribunalfinder.service.gov.uk/courts.json")
courts_array = JSON.parse(courts_json.read)

crown_courts = courts_array.select{ |court| court['court_types'].include?('Crown Court') }

crown_courts.each do |crown_court|
  Court.find_or_create_by(name: crown_court['name'])
end
