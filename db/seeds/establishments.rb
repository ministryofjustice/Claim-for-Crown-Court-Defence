require Rails.root.join('db','seeds', 'establishments', 'prison_seeder')

options = { dry_run: ENV['SEEDS_DRY_MODE'] }

Seeds::Establishments::PrisonSeeder.call(options)
