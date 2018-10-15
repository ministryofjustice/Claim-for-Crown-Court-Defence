namespace :establishments do
  desc 'Seed establishments into the database (prefix with SEEDS_DRY_MODE=false to disable DRY mode)'
  task :seed => :environment do
    ENV['SEEDS_DRY_MODE'] = 'true' unless ENV['SEEDS_DRY_MODE'].present?
    load("#{Rails.root}/db/seeds/establishments.rb")
  end

  desc 'Remove previously seeded establishments'
  task :delete, [:id, :category] => :environment do |_t, args|
    ENV['SEEDS_DRY_MODE'] = 'true' unless ENV['SEEDS_DRY_MODE'].present?
    @dry_run = ENV['SEEDS_DRY_MODE']!='false'
    delete_record(args)
  end

  private

  def delete_record(args)
    establishment = Establishment.find_by(id: args[:id], category: args[:category])
    raise "No establishment found of type #{args[:category]} with id #{args[:id]}" unless establishment.present?
    establishment.delete unless @dry_run
    log args[:category], "[DELETED] Deleted #{args[:category]} with id #{args[:id]}"
  end

  def log(category, message, stdout: false)
    log_parts = ["[#{category.humanize.upcase}]"]
    log_parts << '[DRY RUN]' if @dry_run
    log_parts << message
    output = log_parts.join(' ')
    Rails.logger.info output
    puts output if stdout
  end
end
