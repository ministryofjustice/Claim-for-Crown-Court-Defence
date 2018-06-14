namespace :providers do
  namespace :lgfs_supplier_numbers do
    desc 'Seed supplier data info (prefix with SEEDS_DRY_MODE=false to disable DRY mode)'
    task seed_data: :environment do
      require "#{Rails.root}/db/provider_suppliers_data_seeder"
      options = {}
      options[:dry_run] = ENV['SEEDS_DRY_MODE'].present? ? ENV['SEEDS_DRY_MODE'] : 'true'
      options[:seed_file] = ENV['SEED_FILE_PATH'] if ENV['SEED_FILE_PATH'].present?
      Db::ProviderSuppliersDataSeeder.call(options)
    end
  end
end
