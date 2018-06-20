require Rails.root.join('db','seeds', 'establishments', 'prison_seeder')
require Rails.root.join('db','seeds', 'establishments', 'hospital_seeder')
require Rails.root.join('db','seeds', 'establishments', 'magistrates_court_seeder')
require Rails.root.join('db','seeds', 'establishments', 'crown_court_seeder')

options = { dry_run: ENV['SEEDS_DRY_MODE'] }

Seeds::Establishments::PrisonSeeder.call(options)
Seeds::Establishments::HospitalSeeder.call(options)
Seeds::Establishments::MagistratesCourtSeeder.call(options)
Seeds::Establishments::CrownCourtSeeder.call(options)
